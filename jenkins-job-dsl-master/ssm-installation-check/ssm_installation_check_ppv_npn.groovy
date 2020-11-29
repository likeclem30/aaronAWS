job('aws_cli/ssm_installation_report') {
    scm 
    {
            git {
                branch('*/describe-cli')
                remote {
                    url("git@git.mckinsey-solutions.com:mash-periscope/ppv-aws-cli.git")
                    credentials('087a0a62-3c2b-4aff-9e0b-fd9ecd346a44')
                }
            }
        }
    triggers {
        scm('H/5 * * * *')
    }
    steps {
        shell("ls -lrth /var/jenkins_home")
    }
}