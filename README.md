# NAME

Dancer2::Template::TemplateFlute - Template::Flute wrapper for Dancer2

# VERSION

Version 0.201

# DESCRIPTION

This class is an interface between Dancer2's template engine abstraction layer
and the [Template::Flute](https://metacpan.org/pod/Template::Flute) module.

In order to use this engine, use the template setting:

    template: template_flute

The default template extension is ".html".

## LAYOUT

Each layout needs a specification file and a template file. To embed
the content of your current view into the layout, put the following
into your specification file, e.g. `views/layouts/main.xml`:

    <specification>
    <value name="content" id="content" op="hook"/>
    </specification>

This replaces the contents of the following block in your HTML
template, e.g. `views/layouts/main.html`:

    <div id="content">
    Your content
    </div>

## ITERATORS

Iterators can be specified explicitly in the configuration file as below.

    engines:
      template:
        template_flute:
          iterators:
            fruits:
              class: JSON
              file: fruits.json

## FILTER OPTIONS

Filter options and classes can be specified in the configuration file as below.

    engines:
      template:
        template_flute:
          filters:
            currency:
              options:
                int_curr_symbol: "$"
            image:
              class: "Flowers::Filters::Image"

## ADJUSTING URIS

We automatically adjust links in the templates if the value of
`request-`path> is different from `request-`path\_info>.

## EMBEDDING IMAGES IN EMAILS

If you pass a value named `email_cids`, which should be an empty hash
reference, all the images `src` attributes will be rewritten using
the CIDs, and the reference will be populated with an hashref, as
documented in [Template::Flute](https://metacpan.org/pod/Template::Flute)

Further options for the CIDs should be passed in an optional value
named `cids`. See [Template::Flute](https://metacpan.org/pod/Template::Flute) for them.

## DISABLE OBJECT AUTODETECTION

Sometimes you want to pass values to a template which are objects, but
don't have an accessor, so they should be treated like hashrefs instead.

You can specify classes with the following syntax:

    engines:
      template:
        template_flute:
          autodetect:
            disable:
              - My::Class1
              - My::Class2

The class matching is checked by [Template::Flute](https://metacpan.org/pod/Template::Flute) with `isa`, so
any parent class would do.

## LOCALIZATION

Templates can be localized using the Template::Flute::I18N module. You
can define a class that provides a method which takes as first (and
only argument) the string to translate, and returns the translated
one. You have to provide the class and the method. If the class is not
provided, no localization is done. If no method is specified,
'localize' will be used. The app will crash if the class doesn't
provide such method.

**Be sure to return the argument verbatim if the module is not able to
translate the string**.

Example configuration, assuming the class `MyApp::Lexicon` provides a
`try_to_translate` method.

    engines:
      template:
        template_flute:
          i18n:
            class: MyApp::Lexicon
            method: try_to_translate

A class could be something like this:

    package MyTestApp::Lexicon;
    use Dancer2;

    sub new {
        my $class = shift;
        debug "Loading up $class";
        my $self = {
                    dictionary => {
                                   en => {
                                          'TRY' => 'Try',
                                         },
                                   it => {
                                          'TRY' => 'Prova',
                                         },
                                  }
                   };
        bless $self, $class;
    }

    sub dictionary {
        return shift->{dictionary};
    }

    sub try_to_translate {
        my ($self, $string) = @_;
        my $lang = session('lang') || var('lang');
        return $string unless $lang;
        return $string unless $self->dictionary->{$lang};
        my $tr = $self->dictionary->{$lang}->{$string};
        defined $tr ? return $tr : return $string;
    }

    1;

Optionally, you can pass the options to instantiate the class in the
configuration. Like this:

    engines:
      template:
        template_flute:
          i18n:
            class: MyApp::Lexicon
            method: localize
            options:
              append: 'X'
              prepend: 'Y'
              lexicon: 'path/to/po/files'

This will call

    MyApp::Lexicon->new(append => 'X', prepend => 'Y', lexicon => 'path/to/po/files');

when the engine is initialized, and will call the `localize` method
on it to get the translations.

## DEBUG TOOLS

If you set `check_dangling` in the engine stanza, the specification
will run a check (using the [Template::Flute::Specification](https://metacpan.org/pod/Template::Flute::Specification)'s
`dangling` method) against the template to see if you have elements
of the specifications which are not bound to any HTML elements.

In this case a debug message is issued (so keep in mind that with
higher logging level you are not going to see it).

Example configuration:

    engines:
      template:
        template_flute:
          check_dangling: 1

When the environment is set to `development` this feature is turned
on by default. You can silence the logs by setting:

    engines:
      template:
        template_flute:
          disable_check_dangling: 1

## FORMS

Dancers::Template::TemplateFlute has a form plugin
[Dancer2::Plugin::TemplateFlute](https://metacpan.org/pod/Dancer2::Plugin::TemplateFlute) which must be installed in order to use
[Template::Flute](https://metacpan.org/pod/Template::Flute) forms.

The token `form` is reserved for forms. It can be a single
[Dancer2::Plugin::TemplateFlute](https://metacpan.org/pod/Dancer2::Plugin::TemplateFlute) form object or an arrayref of
[Dancer2::Plugin::TemplateFlute](https://metacpan.org/pod/Dancer2::Plugin::TemplateFlute) form objects.

### Typical usage for a single form.

#### XML Specification

    <specification>
    <form name="registration" link="name">
    <field name="email"/>
    <field name="password"/>
    <field name="verify"/>
    </form>
    </specification>

#### HTML

    <form class="frm-default" name="registration" action="/register" method="POST">
          <fieldset>
            <div class="reg-info">Info</div>
            <ul>
                  <li>
                    <label>Email</label>
                    <input type="text" name="email"/>
                  </li>
                  <li>
                    <label>Password</label>
                    <input type="text" name="password"/>
                  </li>
                  <li>
                    <label>Confirm password</label>
                    <input type="text" name="verify" />
                  </li>
                  <li>
                    <input type="submit" value="Register" class="btn-submit" />
                  </li>
            </ul>
          </fieldset>
    </form>

#### Code

    any [qw/get post/] => '/register' => sub {
        my $form = request->is_post
            ? form('registration', source => 'body')
            : form('registration', source => 'session' );
        my %values = %{$form->values};
        # VALIDATE, filter, etc. the values
        template register => {form => $form };
    };

### Usage example for multiple forms

#### Specification

    <specification>
    <form name="registrationtest" link="name">
    <field name="emailtest"/>
    <field name="passwordtest"/>
    <field name="verifytest"/>
    </form>
    <form name="logintest" link="name">
    <field name="emailtest_2"/>
    <field name="passwordtest_2"/>
    </form>
    </specification>

#### HTML

    <h1>Register</h1>
    <form class="frm-default" name="registrationtest" action="/multiple" method="POST">
          <fieldset>
            <div class="reg-info">Info</div>
            <ul>
                  <li>
                    <label>Email</label>
                    <input type="text" name="emailtest"/>
                  </li>
                  <li>
                    <label>Password</label>
                    <input type="text" name="passwordtest"/>
                  </li>
                  <li>
                    <label>Confirm password</label>
                    <input type="text" name="verifytest" />
                  </li>
                  <li>
                    <input type="submit" name="register" value="Register" class="btn-submit" />
                  </li>
            </ul>
          </fieldset>
    </form>
    <h1>Login</h1>
    <form class="frm-default" name="logintest" action="/multiple" method="POST">
          <fieldset>
            <div class="reg-info">Info</div>
            <ul>
                  <li>
                    <label>Email</label>
                    <input type="text" name="emailtest_2"/>
                  </li>
                  <li>
                    <label>Password</label>
                    <input type="text" name="passwordtest_2"/>
                  </li>
                  <li>
                    <input type="submit" name="login" value="Login" class="btn-submit" />
                  </li>
            </ul>
          </fieldset>
    </form>

#### Code

    any [qw/get post/] => '/multiple' => sub {
        my ( $login_form, $registration_form );
        debug to_dumper({params});

        if (params->{login}) {
            $login_form = form('logintest', source => 'parameters');
            my %vals = %{$login->values};
            # VALIDATE %vals here
        }
        else {
            # pick from session
            $login_form = form('logintest', source => 'session');
        }

        if (params->{register}) {
            $registration_form = form('registrationtest', source => 'parameters');
            my %vals = %{$registration->values};
            # VALIDATE %vals here
        }
        else {
            # pick from session
            $registration_form = form('registrationtest', source => 'session');
        }
        template multiple => { form => [ $login_form, $registration_form ] };
    };

# METHODS

## default\_tmpl\_ext

Returns default template extension.

## render TEMPLATE TOKENS

Renders template TEMPLATE with values from TOKENS.

# SEE ALSO

[Dancer2](https://metacpan.org/pod/Dancer2), [Template::Flute](https://metacpan.org/pod/Template::Flute)

# AUTHOR

Author of the original Dancer module:

Stefan Hornburg (Racke), `<racke at linuxia.de>`

Conversion to Dancer2:

Peter Mottram (SysPete), `<peter@sysnix.com>`

Author of the original version of this Dancer2 module:

William Carr (mrmaloof), `<bill at bottlenose-wine.com>`

# BUGS

Please report any bugs or feature requests via the GitHub issue tracker at:
[https://github.com/interchange/Dancer2-Template-TemplateFlute/issues](https://github.com/interchange/Dancer2-Template-TemplateFlute/issues)

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer2::Template::TemplateFlute

You can also look for information at:

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Dancer2-Template-TemplateFlute](http://annocpan.org/dist/Dancer2-Template-TemplateFlute)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Dancer2-Template-TemplateFlute](http://cpanratings.perl.org/d/Dancer2-Template-TemplateFlute)

- meta::cpan

    [https://metacpan.org/pod/Dancer2::Template::TemplateFlute](https://metacpan.org/pod/Dancer2::Template::TemplateFlute)

# LICENSE AND COPYRIGHT

Copyright 2011-2016 Stefan Hornburg (Racke) &lt;racke@linuxia.de>.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
