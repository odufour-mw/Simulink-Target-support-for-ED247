updateGitlabCommitStatus state: 'pending'

releases = [
    'r2016b',
    'r2017b',
    'r2018b',
    'r2019b',
	'r2020b'
]

pipeline {

	agent { label 'WIN' }

	options {
		gitLabConnection('Consulting FR')
	}

    environment {

        USERPROFILE = 'C:\\Temp'
        MW_MINGW64_LOC = '\\\\gnb-csg-win01\\c$\\MinGW\\4.9.2-posix'
        ED247_LOC = 'C:\\Temp\\ed247'
        LIBXML_LOC = 'C:\\Temp\\libxml2'

		// cf http://inside.mathworks.com/wiki/Using_MW_CRASH_MODE
		MW_CRASH_MODE = 'none'

	}

	stages {
        
		stage ('Tests and packages'){

			steps {
				script {
					def jobPerRelease = [:]
					releases.each { release ->
						jobPerRelease[release] = pipelineByRelease(release)
					}
					parallel jobPerRelease
				}
			}

		}
		
		stage('Publish') {

			agent {
				label 'LINUX'
			}
			steps {

				script {

					catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
						sh """
						rm *.tap
						"""
					}

					releases.each { release ->
						publishResults(release)
					}
					step([$class: "TapPublisher", testResults: "*.tap"])
					
                    catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') { 
                        cobertura coberturaReportFile: '*.xml'			
                    }

				}
			}			
		}
		
	}

	post {
		always {
			archiveArtifacts allowEmptyArchive: true, artifacts: '*.mltlbx'
			emailext attachLog: true, attachmentsPattern: '*.pdf',
				body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
				recipientProviders: [developers(), requestor()],
				subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}"			
			cleanWs cleanWhenAborted: false, cleanWhenFailure: false, cleanWhenNotBuilt: false, cleanWhenUnstable: false, notFailBuild: true, deleteDirs:true
		}
		success {
			updateGitlabCommitStatus name: 'build', state: 'success'
		}
		failure {
			updateGitlabCommitStatus name: 'build', state: 'failed'
		}
		aborted  {
			updateGitlabCommitStatus name: 'build', state: 'canceled'
		}
	}

}

def pipelineByRelease(release){

	return { 

		node("WIN"){

            stage("Package $release") {

                checkout scm

				catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
					bat """
					mw -using $release:perfect matlab -wait -logfile "C:%WORKSPACE%/package.log" -r "exit(ci.package())"
					"""
				}
				catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') { 
					bat """
					type "C:%WORKSPACE:/=\\%\\package.log"
					"""
				}
				catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
					stash includes: "*.mltbx", name: "toolbox-$release"
				}

			}
		
			stage("Prepare $release") {
								
				catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
					bat """
					mw -using $release:perfect matlab -wait -logfile "C:%WORKSPACE%/install.log" -r "exit(ci.install())"
					"""
				}
				catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') { 
					bat """
					type "C:%WORKSPACE:/=\\%\\install.log"
					"""
				}

			}

			stage("Test $release") {

				catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
					bat """
					mw -using $release:perfect matlab -wait -logfile "C:%WORKSPACE%/test.log" -r "exit(ci.test())"
					"""
				}
				catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') { 
					bat """
					type "C:%WORKSPACE:/=\\%\\test.log"
					"""
				}
				catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
					stash includes: "*.tap", name: "tap-$release"
					stash includes: "*.pdf", name: "report-$release"
					stash includes: "*.xml", name: "coverage-$release"
				}

			}
									
			stage("Cleanup $release") {

				catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
					bat """
					mw -using $release:perfect matlab -wait -logfile "C:%WORKSPACE%/cleanup.log" -r "exit(ci.cleanup())"
					"""
				}
				catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') { 
					bat """
					type "C:%WORKSPACE:/=\\%\\cleanup.log"
					"""
				}

			}

		}

	}

}

def publishResults(release) {

	catchError(buildResult: 'SUCCESS', message: 'unstash') {
		unstash name: "tap-$release"
	}
	catchError(buildResult: 'SUCCESS', message: 'unstash') {
		unstash name: "report-$release"
	}
	catchError(buildResult: 'SUCCESS', message: 'unstash') {
		unstash name: "coverage-$release"
	}
	catchError(buildResult: 'SUCCESS', message: 'unstash') {
		unstash name: "toolbox-$release"
	}

}