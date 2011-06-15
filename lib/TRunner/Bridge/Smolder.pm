package TRunner::Bridge::Smolder;
# ABSTRACT: TRunner Smolder Brigde ## wtf description..
use Any::Moose;
use namespace::autoclean;
use TRunner::Bridge::Smolder::Uploader;
use HTTP::BrowserDetect;
use LWP::UserAgent;
use Web::Query;
use Archive::Tar;
use YAML;
use Encode;

# Dancer Request
has user_agent => (
  is => 'ro',
  isa => 'Str',
);

# Query Parameters
has params => (
  is => 'ro',
  required => 1,
);

# Smolder Configuration
has config => (
  is => 'ro',
);

sub _generate_tap_archive {
  my $self = shift;

  my $test_num = $self->params->{numTestTotal};
  my $tar = Archive::Tar->new;
  my @files;
  for my $idx (1 .. $test_num) {
    last unless my $html = $self->params->{'testTable.'.$idx};
    my $q = Web::Query->new_from_html($html);
    my $title = $q->find('tr.title')->text();
    my @cases;
    $q->find('tr')->each(sub{
      my ($i, $elm) = @_;
      return if $i < 1;
      my $class_attr = $elm->attr('class');
      my $status = 'ok';
      $status = 'not ok' if (!$class_attr || ($class_attr && $class_attr =~ /failed/));
      my ($command, $value, $comment) = $elm->find('td')->text();
      push @cases, {
        id      => $i,
        status  => $status,
        command => $command,
        value   => $value,
        comment => $comment,
      };
    });
    my $str = $self->_generate_tap_string([ @cases ]);
    my $filename = sprintf 't/%03d.t', $idx;
    $tar->add_data($filename, Encode::encode_utf8($str));
    push @files, $filename;
  }
  $tar->add_data('meta.yml', $self->_generate_tap_meta_string(\@files));
  $tar->write('files.tar.gz', COMPRESS_GZIP);
}

sub _detect_client {
  my $self = shift;

  my $browser = HTTP::BrowserDetect->new($self->user_agent);
  {
    architecture => $browser->os_string(),
    platform     => $browser->browser_string(),
  };
}

sub _generate_tap_meta_string {
  my ($self, $files) = @_;

  my $data = {
    start_time => time() - ($self->params->{totalTime} || 0),
    end_time   => time(),
  };

  for my $file (@{ $files }) {
    push @{ $data->{file_attributes} }, {
      description => $file,
      start_time  => time() - 5, #fake
      end_time    => time(),     #fake
    };
    push @{ $data->{file_order} }, $file;
  }
  YAML::Dump($data);
}

sub _generate_tap_string {
  my ($self, $cases) = @_;

  my @rows;
  my $num = 0;
  for my $case (@{ $cases }) {
    push @rows, (sprintf '%s %d - [%s] [%s] [%s]', map { $case->{$_} } qw/status id command value comment/);
    $num = $case->{id};
  }
  return join("\n", '1..'.$num, @rows);
}

sub upload {
  my $self = shift;

  $self->_generate_tap_archive();
  my $client_info = $self->_detect_client();
  my $class = __PACKAGE__ . "::Uploader";
  my $uploader = $class->new(
    %{ $client_info },
    %{ $self->config },
    file => 'files.tar.gz',
  );
  my $status = $uploader->upload;
  return $status;
}

__PACKAGE__->meta->make_immutable();

1;
