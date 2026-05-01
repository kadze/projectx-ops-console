@Library('routebox-shared@main') _

// ops-console deploy pipeline.
//
// Same shape as the other apps with one important addition: there's a
// `rails db:migrate` step AFTER the deploy that runs Rails-native
// migrations against the live env. This step has NO approval gate —
// migrations run wherever the deploy lands. This is the README's
// "There is no environment-by-environment gate for these — they run
// wherever the deploy lands" smell, made explicit.
//
// The Rails migrations are SEPARATE from the Flyway runMigrations
// shared-library function (that one is for routebox-db-migrations'
// repo and is invoked by its own pipeline). Both can produce schema
// changes against the same Postgres. They do not coordinate. We've
// talked about a single coordinated pipeline. We have not built it.

pipeline {

    agent { label 'docker' }

    options {
        timestamps()
        ansiColor('xterm')
        timeout(time: 75, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '50'))
        disableConcurrentBuilds()
    }

    environment {
        SERVICE = 'ops-console'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_SHA = sh(returnStdout: true, script: 'git rev-parse --short=7 HEAD').trim()
                }
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker compose -f docker-compose.test.yml up \\
                      --abort-on-container-exit \\
                      --exit-code-from test-runner \\
                    || true
                '''
                junit allowEmptyResults: true, testResults: 'test-results/junit.xml'
            }
        }

        stage('Build') {
            steps {
                script {
                    env.IMAGE_TAG = buildAndPushImage(service: env.SERVICE)
                }
            }
        }

        stage('Deploy-Dev') {
            steps {
                deployToEcs(service: env.SERVICE, env: 'dev', imageTag: env.IMAGE_TAG)
            }
        }

        stage('Rails db:migrate (dev)') {
            // No approval gate. Runs every deploy. Yes, that means schema
            // changes can go to dev concurrently with whatever else is
            // happening. We've shipped this way for years.
            //
            // The $DEV_/$STAGING_/$PROD_PRIVATE_SUBNETS and *_ECS_SG vars
            // below are Jenkins global env vars — set in the Jenkins UI
            // ("Manage Jenkins" → "System" → Global properties), NOT in
            // this repo. Platform team populated them at initial server
            // setup. If you're staring at "where do these come from" go
            // poke around there.
            steps {
                sh """
                    aws ecs run-task \\
                      --region us-east-1 \\
                      --cluster routebox-dev \\
                      --launch-type FARGATE \\
                      --task-definition routebox-dev-ops-console-migrate \\
                      --overrides '{"containerOverrides":[{"name":"ops-console","command":["bundle","exec","rake","db:migrate"]}]}' \\
                      --network-configuration 'awsvpcConfiguration={subnets=[\$DEV_PRIVATE_SUBNETS],securityGroups=[\$DEV_ECS_SG]}'
                """
            }
            post {
                success { notifySlack(env: 'dev', status: 'ok',   text: "ops-console rails db:migrate (dev) OK") }
                failure { notifySlack(env: 'dev', status: 'fail', text: "ops-console rails db:migrate (dev) FAILED — check the run-task logs in CloudWatch") }
            }
        }

        stage('Approval-Staging') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: "Promote ${env.IMAGE_TAG} to STAGING?", ok: 'Promote'
                }
            }
        }

        stage('Deploy-Staging') {
            steps {
                deployToEcs(service: env.SERVICE, env: 'staging', imageTag: env.IMAGE_TAG)
            }
        }

        stage('Rails db:migrate (staging)') {
            steps {
                sh """
                    aws ecs run-task \\
                      --region us-east-1 \\
                      --cluster routebox-staging \\
                      --launch-type FARGATE \\
                      --task-definition routebox-staging-ops-console-migrate \\
                      --overrides '{"containerOverrides":[{"name":"ops-console","command":["bundle","exec","rake","db:migrate"]}]}' \\
                      --network-configuration 'awsvpcConfiguration={subnets=[\$STAGING_PRIVATE_SUBNETS],securityGroups=[\$STAGING_ECS_SG]}'
                """
            }
            post {
                success { notifySlack(env: 'staging', status: 'ok',   text: "ops-console rails db:migrate (staging) OK") }
                failure { notifySlack(env: 'staging', status: 'fail', text: "ops-console rails db:migrate (staging) FAILED") }
            }
        }

        stage('Approval-Prod') {
            steps {
                timeout(time: 60, unit: 'MINUTES') {
                    input message: "Promote ${env.IMAGE_TAG} to PROD?", ok: 'Deploy to prod'
                }
            }
        }

        stage('Deploy-Prod') {
            steps {
                deployToEcs(service: env.SERVICE, env: 'prod', imageTag: env.IMAGE_TAG)
            }
        }

        stage('Rails db:migrate (prod)') {
            // Still no approval gate. Yes, that means a single-click prod
            // approval upstream of this stage commits us to running prod
            // migrations. The README owns this.
            steps {
                sh """
                    aws ecs run-task \\
                      --region us-east-1 \\
                      --cluster routebox-prod \\
                      --launch-type FARGATE \\
                      --task-definition routebox-prod-ops-console-migrate \\
                      --overrides '{"containerOverrides":[{"name":"ops-console","command":["bundle","exec","rake","db:migrate"]}]}' \\
                      --network-configuration 'awsvpcConfiguration={subnets=[\$PROD_PRIVATE_SUBNETS],securityGroups=[\$PROD_ECS_SG]}'
                """
            }
            post {
                success { notifySlack(env: 'prod', status: 'ok',   text: "ops-console rails db:migrate (prod) OK") }
                failure { notifySlack(env: 'prod', status: 'fail', text: "ops-console rails db:migrate (prod) FAILED — check CloudWatch run-task logs and roll back if needed") }
            }
        }
    }
}
