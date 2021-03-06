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
  include automake
  include dnsmasq
  class { 'git' : version => '2.5.0' }
  include hub
  include nginx
  include vagrant
  include wget
  #include docker
  include awscli
  include virtualbox
  include skype
  include vim
  vim::bundle { [
  'scrooloose/syntastic',
  'garbas/vim-snipmate',
  'MarcWeber/vim-addon-mw-utils',
  'tomtom/tlib_vim',
  'honza/vim-snippets',
  'rodjek/vim-puppet',
]: }
  include iterm2::stable
  include screen
  include chrome
  include evernote
  include colloquy
  include googledrive
#  include google_music_manager
  include android_file_transfer
  include tmux
  include java
  class { 'osx::dock::position':
    position => 'right'
  }
  osx::recovery_message { 'If this Mac is found, please call 301-802-3147': }
  include bash
  include bash::completion
  include sysctl
  #include postgresql
  #include mongodb
  include xquartz
  # include python

  #class { 'intellij':
  #edition => 'ultimate',
  #  version => '14.0.2'
  #}

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.6': }
  nodejs::version { 'v0.8': }
  nodejs::version { 'v0.10': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
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
