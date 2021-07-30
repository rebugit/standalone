#!/usr/bin/env node

const execa = require('execa')
const semanticRelease = require('semantic-release')
const Docker = require('dockerode');
const path = require("path");
const AWS = require("aws-sdk");

const docker = new Docker({socketPath: '/var/run/docker.sock'});
const ecr = new AWS.ECRPUBLIC({region: process.env.AWS_REGION, apiVersion: '2020-10-30'})

const workloads = [
  {
    name: 'authentication',
    path: 'authentication/keycloak',
    imageName: 'keycloak'
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
  const stream = await docker.buildImage(
    {context: path.join(__dirname, workload.path)},
    {t: `${workload.imageName}:${version}`},
  )

  await attachSTOUTtoStream(stream)
  console.log(`Building ${workload.imageName} DONE`)
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

async function pushImages(tag, workload, auth) {
  const repo = process.env.ECR_REPOSITORY_URL
  const sourceImage = `${workload.imageName}:${tag}`
  const targetImage = `${repo}/${sourceImage}`
  const image = await docker.getImage(sourceImage);

  console.log("Tagging image:", sourceImage, "==>", targetImage)

  await image.tag({name: sourceImage, repo: `${repo}/${workload.imageName}`, tag: tag})

  const taggedImage = await docker.getImage(targetImage);

  const stream = await taggedImage.push({name: targetImage, authconfig: auth});
  await attachSTOUTtoStream(stream)
  console.log(`Pushing ${targetImage} DONE`)
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

async function pipeline() {
  const version = await release();
  if (!version) {
    return
  }

  const auth = await dockerLogin();

  for (const workloadsKey in workloads) {
    const workload = workloads[workloadsKey]
    await build(version, workload)
    await pushImages(version, workload, auth)
  }
}

pipeline().then().catch(e => {
  console.error(e)
  process.exit(1)
})