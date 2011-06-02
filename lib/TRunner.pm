package TRunner;
use utf8;
use Dancer ':syntax';
use TRunner::Bridge::Smolder;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/test-runner' => sub {
  template 'test-runner', {}, { layout => undef };
};

get '/test-case/:name' => sub {
    my $name = params->{name};
    my $test_col = config->{selenium}->{TestCase}->{$name};
    send_error("Not Found", 404) unless $test_col;
    template 'test-case', { tcase => $test_col }, { layout => undef };
};

get '/test-suite' => sub {
  template 'test-suite', { tsuite => config->{selenium}->{TestSuite} }, { layout => undef };
};

post '/post-results' => sub {
  my %params = params;
  my $smolder = TRunner::Bridge::Smolder->new(
    "user_agent" => request->user_agent,
    "params"  => \%params,
    "config"  => config->{smolder},
  );
  $smolder->upload;
  template 'post-results', {}, { layout => undef };
};

before_template sub {
  my $tokens = shift;
  $tokens->{uri_base} = request->uri_base;
};

true;
