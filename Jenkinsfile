//def targets = ['cheri256', 'cheri128']
def targets = ['cheri256']
def jobs = [:]
for (x in targets) {
    def target = x // Need to bind the label variable before the closure - can't do 'for (label in labels)'
    // Create a map to pass in to the 'parallel' step so we can fire all the builds at once
    jobs[target] = {
        node('docker') {
            pwd()
            // build steps that should happen on all nodes go here
            def sdkImage = docker.image("ctsrd/cheri-sdk-${target}:latest")
            sdkImage.pull() // make sure we have the latest available from Docker Hub
            stage("build ${target}") {
                dir('nginx') {
                    checkout scm
                }
                dir ('cheribuild') {
                    git 'https://github.com/CTSRD-CHERI/cheribuild.git'
                }
                sdkImage.inside {
                    env.CPU = target
                    env.ISA = 'vanilla'
                    env.INSTALL_PREFIX = "/tmp/benchdir/nginx-${env.CPU}-${env.ISA}"
                    ansiColor('xterm') {
                        sh '''
                             echo Running in SDK image
                             env
                             pwd
                             cd $WORKSPACE
                             ls -la
                             ./cheribuild/jenkins-cheri-build.py nginx --tarball --install-prefix "/tmp/benchdir/nginx-$CPU" --with-libstatcounters --nginx/no-debug-info
                             '''
                    }
                }
                sh 'ls -la'
                archiveArtifacts allowEmptyArchive: true, artifacts: "nginx-${CPU}.tar.xz", fingerprint: true, onlyIfSuccessful: false
            }
            stage("test ${target}") {
                sdkImage.inside {
                    sh 'qemu-system-cheri --help'
                }
            }
        }
    }
}

parallel jobs