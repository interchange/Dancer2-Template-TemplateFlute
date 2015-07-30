#!perl

use strict;
use warnings;

use Dancer qw/:tests/;
use Dancer::Plugin::Form;
use Data::Dumper;
use Test::More tests => 8;

set session => 'simple';
set logger => 'console';
set log => 'error';

my $form = form('main');
$form->errors({ mail => 'not valid' });
is_deeply($form->error_tokens, { error_mail => 'not valid'});
is_deeply($form->errors, [ { name => 'mail', label => 'not valid' } ]);

$form->errors({ mail => ['not valid', 'invalid'], year => 'random'  });
is_deeply($form->error_tokens, {
                                error_mail => 'not valid, invalid',
                                error_year => 'random',
                               });
is_deeply($form->errors, [
                          { name => 'mail',
                            label => 'not valid, invalid' },
                          {
                           name => 'year',
                           label => 'random',
                          }
                         ]) or diag Dumper($form->errors);

eval {
    $form->errors({ mail => { foo => 'bar' } });
};
ok ($@, "Exception with invalid data");

eval {
    $form->errors([ mail => { foo => 'bar' } ]);
};
ok ($@, "Exception with invalid data");

$form->errors({ test => [qw/first second/] }, joiner => '<br>');
is_deeply($form->errors, [ { name => 'test', label => 'first<br>second' } ],
          "joiner option works");
is_deeply($form->error_tokens(prefix => 'prova',
                              prefix_joiner => '_X_'),
          {
           prova_X_test => 'first<br>second',
          }, "prefix and prefix_joiner options work for error_tokens");
