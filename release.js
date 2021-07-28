#!/usr/bin/env node

const execa = require('execa')
const semanticRelease = require('semantic-release')
const fs = require('fs')
const Docker = require('dockerode');
const path = require("path");
const docker = new Docker({socketPath: '/var/run/docker.sock'});

const workloads = [
  {
    name: 'authentication',
    path: 'authentication/keycloak',
    imageName: 'keycloak'
  }
]

async function fetch() {
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
    const tag = await fetch()
    const version = tag.replace('v', '')
    console.log(`No release published. Current version: ${version}`);
    return version
  }

  return version
}

async function build(version, workload) {
  const stream = await docker.buildImage(
    {context: path.join(__dirname, workload.path)},
    {t: `${workload.imageName}:${version}`},
  )

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

async function buildDocker(version) {
  const jobs = []

  for (const workloadsKey in workloads) {
    const workload = workloads[workloadsKey]
    await build(version, workload)
  }

  await Promise.all(jobs)
}

buildDocker("2.0.1").then(res => {
  console.log(res)
})

// release().then(v => {
//   console.log(v)
//   fs.writeFileSync('version', v, 'utf8')
// }).catch(e => {
//   console.error('The automated release failed with %O', e)
//   process.exit(1)
// })