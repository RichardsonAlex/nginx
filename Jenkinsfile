def targets = ['cheri256', 'cheri128']
def jobs = [:]
for (x in targets) {
    def target = x // Need to bind the label variable before the closure - can't do 'for (label in labels)'

    // Create a map to pass in to the 'parallel' step so we can fire all the builds at once
    jobs[target] = {
        node('docker') {
            // build steps that should happen on all nodes go here
            def sdkImage = docker.image("ctsrd/cheri-sdk-${target}:latest")
            sdkImage.pull() // make sure we have the latest available from Docker Hub
            stage("build ${target}") {
                sdkImage.inside {
                    dir("/") {
                        git(url: 'https://github.com/CTSRD-CHERI/cheribuild.git', changelog: true)
                    }
                    sh '''
                             echo Running in SDK image
                             env
                             pwd
                             ls -la
                             /cheribuild/jenkins-cheri-build.py --help
                             '''
                }
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