#!/usr/bin/perl
use Test::More;

use_ok('MooseX::TransactionalMethods::Meta::Method');

{ package My::SchemaTest;
  use Moose;
  sub txn_do {
      my $code = shift;
      return $code->(@_);
  }
};

my $schema = My::SchemaTest->new();

{ package My::ClassTest1;
  use Moose;
  has 'schema' => (is => 'ro', required => 1);
  no warnings 'once';
  *bla = Moose::Meta::Method->wrap
    (
     sub {
         my $self = shift;
         return 'return '.shift;
     },
     associated_metaclass => MooseX::TransactionalMethods::Meta::Method->meta,
     package_name => 'My::ClassTest1',
     name => 'bla'
    )->body;
};

{ package My::ClassTest2;
  use Moose;
  no warnings 'once';
  *bla = Moose::Meta::Method->wrap
    (
     sub {
         my $self = shift;
         return 'return '.shift;
     },
     associated_metaclass => MooseX::TransactionalMethods::Meta::Method->meta,
     package_name => 'My::ClassTest2',
     name => 'bla',
     schema => $schema
    )->body;
};

my $object1 = My::ClassTest1->new({ schema => $schema });
my $object2 = My::ClassTest2->new();

is($object1->bla('test1'),'return test1',
   'fetching the schema from the instance.');

is($object2->bla('test2'),'return test2',
   'using the schema in the declaration.');

done_testing();

1;
