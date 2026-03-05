import org.jenkinsci.plugins.workflow.steps.FlowInterruptedException

pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t greatfet https://github.com/greatscottgadgets/greatfet.git'
            }
        }
        stage('Build (Host)') {
            agent {
                docker {
                    image 'greatfet'
                    reuseNode true
                }
            }
            steps {
                sh './ci-scripts/build-host.sh'
            }
        }
        stage('Build (Firmware)') {
            agent {
                docker {
                    image 'greatfet'
                    reuseNode true
                }
            }
            steps {
                sh './ci-scripts/build-firmware.sh'
            }
        }
        stage('HIL Test') {
            agent {
                docker {
                    image 'greatfet'
                    reuseNode true
                    args '''
                            --group-add=46
                            --device-cgroup-rule="c 189:* rmw"
                            -v /dev/bus/usb:/dev/bus/usb
                            -v /tmp/req_pipe:/tmp/req_pipe
                            -v /tmp/res_pipe:/tmp/res_pipe
                        '''
                }
            }
            steps {
                retry(3) {
                    script {
                        try {
                            // Allow 20 seconds for the USB hub port power server to respond
                            timeout(time: 20, unit: 'SECONDS') {
                                sh 'hubs all off'
                                sh 'hubs greatfet reset'
                            }
                        } catch (FlowInterruptedException err) {
                            // Check if the cause was specifically an exceeded timeout
                            def cause = err.getCauses().get(0)
                            if (cause instanceof org.jenkinsci.plugins.workflow.steps.TimeoutStepExecution.ExceededTimeout) {
                                echo "USB hub port power server command timeout reached."
                                throw err // Re-throw the exception to fail the build
                            } else {
                                echo "Build interrupted for another reason."
                                throw err // Re-throw the exception to fail the build
                            }
                        } catch (Exception err) {
                            echo "An unrelated error occurred: ${err.getMessage()}"
                            throw err
                        }
                    }
                    sh './ci-scripts/test-host.sh'
                }
                retry(3) {
                    script {
                        try {
                            // Allow 20 seconds for the USB hub port power server to respond
                            timeout(time: 20, unit: 'SECONDS') {
                                sh 'hubs greatfet reset'
                            }
                        } catch (FlowInterruptedException err) {
                            // Check if the cause was specifically an exceeded timeout
                            def cause = err.getCauses().get(0)
                            if (cause instanceof org.jenkinsci.plugins.workflow.steps.TimeoutStepExecution.ExceededTimeout) {
                                echo "USB hub port power server command timeout reached."
                                throw err // Re-throw the exception to fail the build
                            } else {
                                echo "Build interrupted for another reason."
                                throw err // Re-throw the exception to fail the build
                            }
                        } catch (Exception err) {
                            echo "An unrelated error occurred: ${err.getMessage()}"
                            throw err
                        }
                    }
                    sh './ci-scripts/test-firmware-program.sh'
                }
                sh './ci-scripts/test-firmware-flash.sh'
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
