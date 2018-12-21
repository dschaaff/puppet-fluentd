# Configure yumrepo
#
class fluentd::repo::yum (
  $ensure   = 'present',
  $descr    = 'TreasureData',
  $enabled  = '1',
  $gpgcheck = '1',
  $gpgkey   = 'https://packages.treasuredata.com/GPG-KEY-td-agent',
) {
  case $facts['os']['name'] {
    'Amazon': {
      $baseurl = 'http://packages.treasuredata.com/3/amazon/2/\$releasever/\$basearch'
    }
    default: {
      $baseurl = 'http://packages.treasuredata.com/3/redhat/\$releasever/\$basearch'
    }
  }
  yumrepo { 'treasure-data':
    ensure   => $ensure,
    descr    => $descr,
    baseurl  => $baseurl,
    enabled  => $enabled,
    gpgcheck => $gpgcheck,
    notify   => Exec['add GPG key'],
  }

  exec { 'add GPG key':
    command     => "rpm --import ${fluentd::repo::yum::gpgkey}",
    path        => '/bin:/usr/bin/',
    refreshonly => true,
  }

  exec { 'remove old GPG key':
    command => 'rpm -e --allmatches gpg-pubkey-a12e206f-*',
    path    => '/bin:/usr/bin/',
    onlyif  => 'rpm -qi gpg-pubkey-a12e206f-*',
    notify  => Exec['add GPG key'],
  }

}
