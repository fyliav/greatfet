pipeline {
    agent {
        dockerfile {
            args '''
                --group-add=46
                --device-cgroup-rule="c 189:* rmw"
                -v /dev/bus/usb:/dev/bus/usb
                -v /tmp/req_pipe:/tmp/req_pipe
                -v /tmp/res_pipe:/tmp/res_pipe
                '''
        }
    }
    stages {
        stage('Build (Host)') {
            steps {
                sh './ci-scripts/build-host.sh'
            }
        }
        stage('Build (Firmware)') {
            steps {
                sh './ci-scripts/build-firmware.sh'
            }
        }
        stage('Test') {
            steps {
                sh 'hubs all off'
                retry(3) {
                    sh 'hubs greatfet reset'
                    sh './ci-scripts/test-host.sh'
                }
                retry(3) {
                    sh 'hubs greatfet reset'
                    sh './ci-scripts/test-firmware-program.sh'
                }
                sh './ci-scripts/test-firmware-flash.sh'
                sh './ci-scripts/configure-hubs.sh --reset'
            }
        }
    }
    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true)
        }
    }
}
