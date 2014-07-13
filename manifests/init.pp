class iptables {
	$pkg = $operatingsystemrelease ? {
		/^6/ => "iptables",	
		/^7/ => "iptables-services",
	}

	package { $pkg:
			ensure => installed,
	}

	file { "/usr/local/bin/cat_config.sh":
		owner => root,
		group => root,
		mode => 755,
		source => "puppet:///modules/iptables/cat_config.sh",
	}

	file { "/etc/sysconfig/iptables-rules.d":
		owner => root,
		group => root,
		mode => 700,
		ensure => directory,
		recurse => true,
		purge => true,
	}
	file { "/etc/sysconfig/iptables-rules.d/00header":
		owner => root,
		group => root,
		mode => 600,
		source => "puppet:///modules/iptables/rules.d/00header",
		require => File["/etc/sysconfig/iptables-rules.d"],
		notify => Exec["cat_config"],
	}	
	file { "/etc/sysconfig/iptables-rules.d/99footer":
		owner => root,
		group => root,
		mode => 600,
		source => "puppet:///modules/iptables/rules.d/99footer",
		require => File["/etc/sysconfig/iptables-rules.d"],
		notify => Exec["cat_config"],
	}	

	exec { "cat_config":
		command => "/usr/local/bin/cat_config.sh /etc/sysconfig/iptables-rules.d /etc/sysconfig/iptables",
		refreshonly => true,
		require => File["/usr/local/bin/cat_config.sh"],
		notify => Exec["iptables-restore"],
	}
	exec { "iptables-restore":
		command => "/sbin/iptables-restore < /etc/sysconfig/iptables",
		refreshonly => true,
	}

	define rule_fragment($source) {
		file { "/etc/sysconfig/iptables-rules.d/${name}":
			owner	=> 'root',
			group	=> 'root',
			source 	=> $source,
			require => File['/etc/sysconfig/iptables-rules.d'],
			notify 	=> Exec['cat_config'], 
		}
	}

	rule_fragment { '90default':
		source => "puppet:///modules/iptables/rules.d/90default",
	}
}
