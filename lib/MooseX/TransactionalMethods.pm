package MooseX::TransactionalMethods;
use Moose ();
use Moose::Exporter;
use MooseX::TransactionalMethods::Meta::Method;

Moose::Exporter->setup_import_methods
  ( with_meta => [ 'transactional' ],
    also      => [ 'Moose' ],
  );


my $method_metaclass = Moose::Meta::Class->create_anon_class
  (
   superclasses => ['Moose::Meta::Method'],
   roles => ['MooseX::TransactionalMethods::Meta::Method'],
   cache => 1,
  );

sub transactional {
    my $meta = shift;
    my ($name, $schema, $code);

    if (ref($_[1]) eq 'CODE') {
        ($name, $code) = @_;
    } else {
        ($name, $schema, $code) = @_;
    }

    my $m = $method_metaclass->name->wrap
      (
       $code,
       package_name => $meta->name,
       name => $name,
       $schema ? (schema => $schema) : ()
      );

    $meta->add_method($name, $m);
}

1;
