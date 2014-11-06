require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include elasticsearch
  include hipchat
  include sysctl
  include skitch
  include alfred
  include skype
  include spotify
  include redis
  include github_for_mac
  include calibre
   include fonts
    include limechat
  # include authy
  include opera
  include vlc
  include foreman
  include hub
  include charles
  #include cyberduck
  include spectacle
  include selfcontrol
  include kindle
  include dropbox
    include caffeine
    include clojure
  class { 'intellij':
  edition => 'ultimate',
  version => '13.1'

}
  include xquartz
  include sublime_text
 include postgresql
  include osx::global::key_repeat_rate
  include osx::dock::position
  include karabiner #::login_item
karabiner::remap{ 'optionR2controlL': }
include memcached
  include nginx
  include java

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    #fail('Please enable full disk encryption and try again')
  }

  # node versions
  include nodejs::v0_10
  class { 'nodejs::global': version => 'v0.10' }
  # default ruby versions
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
