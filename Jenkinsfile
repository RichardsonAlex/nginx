
def buildProjectWithCheribuild(String projectName, String extraArgs, String targetCPU) {
    def sdkCPU = targetCPU
    if (sdkCPU.startsWith("hybrid-")) {
        sdkCPU = sdkCPU.substring("hybrid-".length())
    }
    // build steps that should happen on all nodes go here
    def sdkImage = docker.image("ctsrd/cheri-sdk-${sdkCPU}:latest")
    // sdkImage.pull() // make sure we have the latest available from Docker Hub
    stage("build ${targetCPU}") {
        dir(projectName) {
            checkout scm
        }
        dir ('cheribuild') {
            git 'https://github.com/CTSRD-CHERI/cheribuild.git'
        }
        sdkImage.inside {
            env.CPU = targetCPU
            env.INSTALL_PREFIX = "/tmp/benchdir/${projectName}-${env.CPU}"
            ansiColor('xterm') {
                sh '''
                         echo Running in SDK image
                         env
                         pwd
                         cd $WORKSPACE
                         ls -la
                         '''
                sh "./cheribuild/jenkins-cheri-build.py ${projectName} --tarball ${extraArgs}"
            }
        }
        sh 'ls -la'
        archiveArtifacts allowEmptyArchive: true, artifacts: "nginx-${CPU}.tar.xz", fingerprint: true, onlyIfSuccessful: false
    }
}

void cheribuildProject(String name, String extraArgs, targets=['cheri256', 'cheri128', 'mips', 'hybrid-cheri128']) {
    targets.collectEntries {
        [(it): {
            node('docker') {
                echo "Building for ${it}"
                buildProjectWithCheribuild(name, extraArgs, it)
            }
        }]
    }
}

stage("Build") {
    parallel cheribuildProject('nginx', '--install-prefix /tmp/benchdir/nginx-$CPU --with-libstatcounters --nginx/no-debug-info')
}