package TRunner;
use utf8;
use Dancer ':syntax';
use TRunner::Bridge::Smolder;
use YAML::XS;
our $VERSION = '0.1';

my $selenium = YAML::XS::LoadFile($ENV{SELENIUM_CONF_PATH} || path(setting('confdir') || setting('appdir'), 'selenium.yml'));

get '/' => sub {
    template 'index', { config => config };
};

get '/test-runner' => sub {
  template 'test-runner';
};

get '/test-case/:name' => sub {
    my $name = params->{name};
    my $test_col = $selenium->{TestCase}->{$name};
    send_error("Not Found", 404) unless $test_col;
    template 'test-case', { tcase => $test_col };
};

get '/test-suite' => sub {
  template 'test-suite', { tsuite => $selenium->{TestSuite} };
};

post '/post-results' => sub {
  my %params = params;

  my $is_passed = 0;
  my $smolder = config->{smolder};
     $smolder->{project_id} ||= $selenium->{project_id};
  
  $is_passed = 1 unless $smolder->{server};
  $is_passed = 1 unless $smolder->{project_id};

  return template 'post-results' if $is_passed;

  my $smolder = TRunner::Bridge::Smolder->new(
    "user_agent" => request->user_agent,
    "params"  => \%params,
    "config"  => $smolder,
  );
  $smolder->upload;
  template 'post-results';
};

before_template sub {
  my $tokens = shift;
  $tokens->{uri_base} = request->uri_base;
};

true;
