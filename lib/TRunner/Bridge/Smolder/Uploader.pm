package TRunner::Bridge::Smolder::Uploader;
use Any::Moose;
use namespace::autoclean;
use WWW::Mechanize;
use Try::Tiny;

has [ 'server', 'project_id', 'username', 'password', 'file' ] => ( is => 'ro', required => 1 );
has [ 'comments', 'architecture', 'platform', 'tags', 'revision' ] => ( is => 'ro' );

has '_mech' => (
  is => 'ro',
  isa => 'WWW::Mechanize',
  default => sub {
    WWW::Mechanize->new();
  }
);

sub base_url {
  my $self = shift;

  sprintf 'http://%s/app', $self->server;
}

sub upload {
  my $self = shift;

  $self->_auth();
  my $is_failed = 0;
  my $report_id = '';
  try {
    $self->_mech->get($self->base_url . '/projects/add_report/'.$self->project_id);
    $self->_mech->form_name('add_report');
    my %fields = ( report_file => $self->file );
    map { $fields{$_} = $self->$_ } grep { $self->$_ } qw/platform architecture tags comments revision/;
    $self->_mech->set_fields(%fields);
    $self->_mech->submit();
    my $content = $self->_mech->content;
    if ($content =~ /#(\d+) Added/) {
      $report_id = $1;
    } else {
      $is_failed = 1;
    }
  }
  catch {
    $is_failed = 1;
  };
  return 0 if $is_failed;
  return $report_id;
}

sub _auth {
  my $self = shift;

  my $is_error = 0;
  try {
    $self->_mech->get($self->base_url . '/public_auth/login');
    $self->_mech->set_fields(
        username => $self->username,
        password => $self->password,
    );
    $self->_mech->submit();
    my $content = $self->_mech->content;
    if ($self->_mech->status ne '200' || $content !~ /Welcome/) {
      $is_error = 1;
    }
  } catch {
    $is_error = 1;
  };
  return 0 if $is_error;
  return 1;
}

__PACKAGE__->meta->make_immutable();

1;
