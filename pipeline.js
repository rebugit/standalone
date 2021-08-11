#!/usr/bin/env node

const execa = require('execa')
const semanticRelease = require('semantic-release')
const Docker = require('dockerode');
const path = require("path");
const AWS = require("aws-sdk");
const ghpages = require('gh-pages');
const util = require('util');
const exec = util.promisify(require('child_process').exec);
const yaml = require('js-yaml');
const fsPromises = require('fs').promises;

const docker = new Docker({socketPath: '/var/run/docker.sock'});
const ecr = new AWS.ECRPUBLIC({region: process.env.AWS_REGION, apiVersion: '2020-10-30'})

const workloads = [
  {
    name: 'authentication',
    path: 'authentication/keycloak',
    imageName: 'keycloak'
  },
  {
    name: 'migrator',
    path: 'db/migrator',
    imageName: 'migrator'
  },
  {
    name: 'postgres',
    path: 'db/postgres',
    imageName: 'postgres'
  }
]

async function getLatestVersion() {
  const {stdout} = await execa('git', ['tag', '--points-at', 'HEAD'])
  return stdout
}

console.log("Environment: ", process.env.ENV)

async function release() {
  const result = await semanticRelease({
    branches: [
      'master',
    ],
    repositoryUrl: process.env.GITHUB_REPOSITORY_URL,
    dryRun: process.env.ENV === 'dev',
    ci: true,
    npmPublish: false
  }, {
    env: {
      ...process.env,
      GITHUB_TOKEN: process.env.GITHUB_TOKEN,
      GIT_AUTHOR_NAME: 'MatteoGioioso'
    },
  });

  let version;

  if (result) {
    const {lastRelease, commits, nextRelease, releases} = result;
    version = nextRelease.version

    console.log(`Published ${nextRelease.type} release version ${nextRelease.version} containing ${commits.length} commits.`);

    if (lastRelease.version) {
      console.log(`The last release was "${lastRelease.version}".`);
    }

    for (const release of releases) {
      console.log(`The release was published with plugin "${release.pluginName}".`);
    }
  } else {
    const tag = await getLatestVersion()
    const version = tag.replace('v', '')
    console.log(`No release published. Current version: ${version}, DONE`);
    return undefined
  }

  return version
}

async function build(version, workload) {
  const image = `${workload.imageName}:${version}`
  const stream = await docker.buildImage(
    {context: path.join(__dirname, workload.path)},
    {t: image},
  )

  await attachSTOUTtoStream(stream)
  console.log(`Building ${workload.imageName} DONE`)
  return image
}


async function dockerLogin() {
  console.log("Get auth token from ecr public...")
  const login = await ecr.getAuthorizationToken().promise();

  return {
    auth: "",
    username: 'AWS',
    password: Buffer
      .from(login.authorizationData.authorizationToken, 'base64')
      .toString('utf-8')
      .replace('AWS:', ''),
    serveraddress: process.env.ECR_REPOSITORY_URL
  };
}

async function tagImage(imageToTag, tag) {
  const imageName = imageToTag.split(':')[0]
  const repo = process.env.ECR_REPOSITORY_URL

  const taggedImage = `${repo}/${imageName}:${tag}`
  const image = await docker.getImage(imageToTag);

  console.log("Tagging image:", imageToTag, "==>", taggedImage)

  await image.tag({
    name: imageToTag,
    repo: `${repo}/${imageName}`,
    tag
  })

  const taggedImageObj = await docker.getImage(taggedImage);

  return {
    taggedImageObj,
    taggedImage
  }
}

async function pushImage(imageObj, imageFullName, auth) {
  const stream = await imageObj.push({name: imageFullName, authconfig: auth});
  await attachSTOUTtoStream(stream)
  console.log(`Pushing ${imageFullName} DONE`)
}

async function attachSTOUTtoStream(stream) {
  await new Promise((resolve, reject) => {
    const pipe = stream.pipe(process.stdout, {
      end: true
    });

    pipe.on('end', () => {
      resolve()
    })

    pipe.on('error', (err) => {
      reject(err)
    })

    stream.on('error', (err) => {
      reject(err)
    })

    stream.on('end', () => {
      resolve()
    })
  })
}

async function helm(version) {
  const chartDomain = "https://rebugit.github.io/standalone"
  // version chart
  console.log("Versioning helm chart")
  const filePath = path.join(__dirname, "helm/Chart.yaml")
  const valuesYaml = await fsPromises.readFile(filePath, 'utf8');
  const values = yaml.load(valuesYaml);
  values.version = version
  const newValues = yaml.dump(values)
  await fsPromises.writeFile(filePath, newValues)

  // build chart: helm dependency update && helm package . -n rebugit
  console.log("Updating, packaging and creating chart index")
  const {stdout, stderr} = await exec(
    `helm dependency update helm/ && helm package helm/ -d docs/ && helm repo index docs --url ${chartDomain}`
  );
  console.log(stdout);
  console.log(stderr);

  // Copy the CNAME
  console.log("Copying assets to docs folder")
  await exec(
    `cp ops/CNAME docs/ && cp ops/index.html docs/`
  );

  // Push everything with ghpages
  console.log("Deploying to github")
  const publishing = () => new Promise((resolve, reject) => {
    ghpages.publish(
      'docs',
      {
        repo: `https://git:${process.env.GITHUB_TOKEN}@github.com/${process.env.GITHUB_REPOSITORY_URL.replace("https://github.com/", "")}`,
        user: {
          name: process.env.GITHUB_USERNAME,
          email: process.env.GITHUB_EMAIL
        }
      },
      function (err) {
        if (err) {
          return reject(err)
        }

        console.log("Chart has been published")
        return resolve()
      }
    );
  })

  await publishing()
}

async function pipeline() {
  const version = await release();
  if (!version) {
    return
  }

  const auth = await dockerLogin();

  for (const workloadsKey in workloads) {
    const workload = workloads[workloadsKey]
    const imageFullName = await build(version, workload);
    const image = await tagImage(imageFullName, version);
    const imageLatest = await tagImage(imageFullName, "latest");
    await pushImage(image.taggedImageObj, image.taggedImage, auth)
    await pushImage(imageLatest.taggedImageObj, imageLatest.taggedImage, auth)
  }

  await helm(version)
}

pipeline().then().catch(e => {
  console.error(e)
  process.exit(1)
})