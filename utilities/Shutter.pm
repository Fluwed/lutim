#! /usr/bin/env perl
###################################################
#
#  Copyright (C) 2010-2011  Vadim Rutkovsky <roignac@gmail.com>, Mario Kemper <mario.kemper@googlemail.com> and Shutter Team
#
#  This file is part of Shutter.
#
#  Shutter is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Shutter is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Shutter; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################

package Lutim;

use lib $ENV{'SHUTTER_ROOT'}.'/share/shutter/resources/modules';

use utf8;
use strict;
use POSIX qw/setlocale/;
use Locale::gettext;
use Glib qw/TRUE FALSE/;

use Shutter::Upload::Shared;
our @ISA = qw(Shutter::Upload::Shared);

my $d = Locale::gettext->domain("shutter-upload-plugins");
$d->dir( $ENV{'SHUTTER_INTL'} );

my %upload_plugin_info = (
    'module'        => "Lutim",
	'url'           => "http://lut.im/",
	'registration'  => "-",
	'description'   => $d->get( "Upload screenshots to lut.im" ),
	'supports_anonymous_upload'	 => TRUE,
	'supports_authorized_upload' => FALSE,
);

binmode( STDOUT, ":utf8" );
if ( exists $upload_plugin_info{$ARGV[ 0 ]} ) {
	print $upload_plugin_info{$ARGV[ 0 ]};
	exit;
}

###################################################

sub new {
	my $class = shift;

	#call constructor of super class (host, debug_cparam, shutter_root, gettext_object, main_gtk_window, ua)
	my $self = $class->SUPER::new( shift, shift, shift, shift, shift, shift );

	bless $self, $class;
	return $self;
}

sub init {
	my $self = shift;

	#do custom stuff here
	use WWW::Mechanize;
	use HTTP::Status;
	use HTTP::Request::Common 'POST';

	$self->{_mech} = WWW::Mechanize->new( agent => "$self->{_ua}", timeout => 20 );
	$self->{_http_status} = undef;

	return TRUE;
}

sub upload {
	my ( $self, $upload_filename, $username, $password ) = @_;

	#store as object vars
	$self->{_filename} = $upload_filename;
	$self->{_username} = $username;
	$self->{_password} = $password;

	my $filesize     = -s $upload_filename;
	my $max_filesize = 15360000;
	if ( $filesize > $max_filesize ) {
		$self->{_links}{'status'} = 998;
		$self->{_links}{'max_filesize'} = sprintf( "%.2f", $max_filesize / 1024 ) . " KB";
		return %{ $self->{_links} };
	}

	utf8::encode $upload_filename;
	utf8::encode $password;
	utf8::encode $username;

	eval{

		my $url = "http://lut.im";
		$self->{_mech}->get($url);
		$self->{_http_status} = $self->{_mech}->status();

		if ( is_success( $self->{_http_status} ) ) {

			$self->{_mech}->request(POST $url,
				Content_Type => 'form-data',
					Content      => [
						file =>  [$upload_filename],
						format => 'json'
					],
			);

			$self->{_http_status} = $self->{_mech}->status();

			if ( is_success( $self->{_http_status} ) ) {
				my $html_file = $self->{_mech}->content;

				my @links = $html_file =~ m/"short":"([^"]+)"/;
				#my @links = $html_file =~ m{ <textarea>(.*)</textarea> }gx;

				$self->{_links}{'view_image'} = $url.'/'.$links[0];
				$self->{_links}{'download_link'} = $url.'/'.$links[0].'?dl';
				$self->{_links}{'twitter_link'} = $url.'/'.$links[0].'?t';

				if ( $self->{_debug} ) {
					print "The following links were returned by http://lut.im:\n";
					print $self->{_links}{'view_image'},"\n";
					print $self->{_links}{'download_link'},"\n";
					print $self->{_links}{'twitter_link'},"\n";
				}

				$self->{_links}{'status'} = $self->{_http_status};
			} else {
				$self->{_links}{'status'} = $self->{_http_status};
			}

		}else{
			$self->{_links}{'status'} = $self->{_http_status};
		}

	};
	if($@){
		$self->{_links}{'status'} = $@;
	}

	return %{ $self->{_links} };

}

1;
