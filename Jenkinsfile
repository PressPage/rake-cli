pipeline {
    agent any
    stages {
        stage('Update master branch') {
            agent any
            steps {
                script {
                def BRANCH = 'master-jenkins'
                    checkout scmGit(
                       branches: [[name: "$BRANCH"]],
                       extensions: [
                           [$class: 'CleanBeforeCheckout'],
                       ],
                       userRemoteConfigs: [[credentialsId: env.GITHUB_PRESSDROID_CREDENTIALS,
                       url: "https://github.com/PressPage/${REPOSITORY}.git"]]
                    )

                    withCredentials([
                        gitUsernamePassword(
                            credentialsId: env.GITHUB_PRESSDROID_CREDENTIALS,
                            gitToolName: 'Default'
                        )
                    ]) {
                        TARGET_BRANCH_REVISION = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                        def force = false
                        def updated = false

                        if ("${TARGET_BRANCH_REVISION}" == "${COMMIT_HASH}") {
                            echo 'Nothing to update.'
                        } else if (does_branch_contain_commit("$BRANCH", "${COMMIT_HASH}") > 0) {
                            sh "git reset --hard ${COMMIT_HASH}"
                            force = true
                            echo "$BRANCH branch will be downgraded to ${COMMIT_HASH}"
                        } else {
                            sh "git merge ${COMMIT_HASH}"
                            updated = true
                            echo "${COMMIT_HASH} merged into $BRANCH"
                        }

                        sh script: "git fetch"
                        sh script: "git branch -v"
                        sh script: "git push ${force ? '--force ' : ''} origin HEAD:${BRANCH}"

                        if (updated) {
                            sh script: "git tag ${RELEASE}"
                            sh script: "git push origin ${RELEASE}"

                            create_github_release("$BRANCH", "$REPOSITORY", "$RELEASE")
                        }
                    }
                }
            }
        }
    }
}
def does_branch_contain_commit(branch, commit) {
    return sh(returnStdout: true, script: "git branch -r --contains $commit | awk '{\$1=\$1;print}' | grep -Fx \"origin/$branch\" | wc -l").toInteger()
}
def create_github_release(branch, repository, release) {
    echo branch
    echo repository
    echo release
    def data = "{\"tag_name\": \"${release}\",\"target_commitish\": \"${branch}\",\"name\": \"${release}\",\"body\": \"${release}\",\"draft\": false,\"prerelease\": false}"

    echo data

    withCredentials([
        gitUsernamePassword(
            credentialsId: env.GITHUB_PRESSDROID_CREDENTIALS,
            gitToolName: 'Default'
        )
    ]) {
        sh "curl -L -X POST -H \"Content-Type: application/json\" -H \"Accept: application/vnd.github+json\" -H \"Authorization: Bearer ${GIT_PASSWORD}\" --data '$data' 'https://api.github.com/repos/PressPage/$repository/releases'"
    }
}
