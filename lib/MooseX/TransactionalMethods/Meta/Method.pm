package MooseX::TransactionalMethods::Meta::Method;
use Moose::Role;
use Moose::Util::TypeConstraints;

subtype 'SchemaGenerator',
  as 'CodeRef';
coerce 'SchemaGenerator',
  from duck_type(['txn_do']),
  via { sub { sub { $_ } } };

has schema =>
  ( is => 'ro',
    isa => 'SchemaGenerator',
    default => sub { sub { shift->schema } },
    coerce => 1 );

around 'wrap' => sub {
    my ($wrap, $method, $code, %options) = @_;

    my $meth_obj;
    $meth_obj = $method->$wrap
      (
       sub {
           my ($self) = @_;
           $meth_obj->schema->($self)->txn_do($code, @_);
       },
       %options
      );
    return $meth_obj;
};

1;
