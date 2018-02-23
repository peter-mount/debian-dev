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
debianVersions = [ '8', '9' ]

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
    debVersion + '-' +
    ( architecture=='' ? '' : ( architecture + '-' ) ) +
    version
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
    upstream('/Public/Alpine/master'),
  ])
])

architectures.each {
  architecture -> node( slaveId( architecture ) ) {
    stage( "Checkout " + architecture ) {
      checkout scm
    }

    debianVersions.each {
      debVersion -> stage( 'Build ' + architecture + ' deb'+debVersion ) {
        sh 'docker pull alpine'
        sh 'docker build -t ' + dockerImage( architecture, debVersion ) + ' .'
      }

      stage( 'Publish ' + architecture + ' deb'+debVersion ) {
        sh 'docker push ' + dockerImage( architecture, debVersion )
      }
    }
  }
}

node( "AMD64" ) {
  debianVersions.each {
    debVersion ->  stage( "Publish MultiArch" + ' deb'+debVersion ) {
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
