// Repository name use, must end with / or be '' for none
repository= 'area51/'

// image prefix
imagePrefix = 'debian-dev'

// The image version, master branch is latest in docker
version=BRANCH_NAME
if( version == 'master' ) {
  version = 'latest'
}

// The architectures to build, in format recognised by docker
architectures = [ 'amd64', 'arm64v8' ]

// The debian versions to build
debianVersions = [ '9', '10' ]

// The slave label based on architecture
def slaveId = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'AMD64'
    case 'arm64v8':
      return 'ARM64'
    default:
      return 'amd64'
  }
}

// The docker image name
// architecture can be '' for multiarch images
def dockerImage = {
  architecture, debVersion -> repository + imagePrefix + ':' +
    debVersion +
    ( architecture=='' ? '' : ( '-' + architecture ) ) +
    ( version=='latest' ? '' : ( '-' + version ) )
}

// The go arch
def goarch = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'amd64'
    case 'arm32v6':
    case 'arm32v7':
      return 'arm'
    case 'arm64v8':
      return 'arm64'
    default:
      return architecture
  }
}

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/peter-mount/alpine/master'),
  ])
])

def buildArch = {
  architecture, debVersion -> node( slaveId( architecture ) ) {
    stage( "Checkout " + architecture ) {
      checkout scm
      sh 'docker pull debian:' + debVersion
    }

    stage( 'Debian-' + debVersion + ' ' + architecture ) {
      sh 'docker build' +
          ' -t ' + dockerImage( architecture, debVersion ) +
          ' --build-arg debVersion=' + debVersion +
          ' .'

      sh 'docker push ' + dockerImage( architecture, debVersion )
    }
  }
}

debianVersions.each {
  debVersion ->
    stage( 'Debian-' + debVersion ) {

      parallel(
        'amd64': {
          buildArch( 'amd64', debVersion )
        },
        'arm32v7': {
          buildArch( 'arm32v7', debVersion )
        },
        'arm64v8': {
          buildArch( 'arm64v8', debVersion )
        }
      )
    }

    node( "AMD64" ) {
      stage( "MultiArch" + ' Debian-'+debVersion ) {
        // The manifest to publish
        multiImage = dockerImage( '', debVersion )

        // Create/amend the manifest with our architectures
        manifests = architectures.collect { architecture -> dockerImage( architecture, debVersion ) }
        sh 'docker manifest create -a ' + multiImage + ' ' + manifests.join(' ')

        // For each architecture annotate them to be correct
        architectures.each {
          architecture -> sh 'docker manifest annotate' +
            ' --os linux' +
            ' --arch ' + goarch( architecture ) +
            ' ' + multiImage +
            ' ' + dockerImage( architecture, debVersion )
        }

        // Publish the manifest
        sh 'docker manifest push -p ' + multiImage
      }
    }

}
