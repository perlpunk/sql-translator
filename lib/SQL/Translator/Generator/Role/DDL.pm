package SQL::Translator::Generator::Role::DDL;

use Moo::Role;
use SQL::Translator::Utils qw(header_comment);

requires '_build_shim';
requires '_build_type_map';
requires '_build_numeric_types';
requires '_build_unquoted_defaults';
requires 'field_type_size';

has shim => (
   is => 'ro',
   handles => [ 'quote' ],
   builder => '_build_shim',
);

has type_map => (
   is => 'ro',
   builder => '_build_type_map',
);

has numeric_types => (
   is => 'ro',
   builder => '_build_numeric_types',
);

has unquoted_defaults => (
   is => 'ro',
   builder => '_build_unquoted_defaults',
);

has add_comments => (
   is => 'ro',
);

has add_drop_table => (
   is => 'ro',
);

# would also be handy to have a required size set if there is such a thing

sub field_name { $_[0]->quote($_[1]->name) }

sub field_comments {
   ( $_[1]->comments ? ('-- ' . $_[1]->comments . "\n ") : () )
}

sub field_nullable { ($_[1]->is_nullable ? $_[0]->nullable : 'NOT NULL' ) }

sub field_default {
  return () if !defined $_[1]->default_value;

  my $val = $_[1]->default_value;
  $val = "'$val'" unless $_[0]->numeric_types->{$_[1]->data_type};
  return ( "DEFAULT $val" )
}

sub field_type {
   my ($self, $field) = @_;

   my $field_type = $field->data_type;
   ($self->type_map->{$field_type} || $field_type).$self->field_type_size($field)
}

sub fields {
  my ($self, $table) = @_;
  ( map $self->field($_), $table->get_fields )
}

sub nullable { 'NULL' }

sub header_comments { header_comment() . "\n" if $_[0]->add_comments }

1;
