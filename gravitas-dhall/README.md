# gravitas-dhall

Dhall bindings for Gravitas. This will let you define and typecheck your Gravitas configuration. It can also be used to template or modularize them.

## Prerequisites

*NOTE*: `gravitas-dhall` has only been tests on version >= 1.16.0 of the [dhall interpreter](https://github.com/dhall-lang/dhall-haskell)

You can find the latest version in the [dhall releases](https://github.com/dhall-lang/dhall-json/releases)

You can also just do the following:
```bash
stack install dhall dhall-json --resolver=nightly
```

## Quick start

In the [types](types) folder you'll find the types for the Gravitas definitions. E.g. here's the type for an AWS EC2 instance.

Since most of the fields in all definitions are optional, for better ergonomics while coding Dhall we also generate default values for all types, in the [default](default) folder. When some fields are required, the default value is a function whose input is a record of required fields, that returns the object with these fields set. E.g. the default for the AWS EC2 instance is [this function](default/aws.ec2.instance.dhall).

### Example: EC2 instance

Let's say we have an instance we want to deploy, that we define like this:

```haskell
-- examples/instance-foo.dhall
{ ami              = "ami-1234567"
, instance_type    = "t2.small"
, security_groups  = ["sg-1234567"]
, tags             = [{key: "foo", value: "bar"}]
}
```

We can then generate an EC2 instance object for this instance that we could import in our Gravitas configuration:

```haskell
-- examples/isntance-gravitas.dhall
   let Instance      = ../types/aws.ec2.instance.dhall
in let SecurityGroup = ../types/aws.ec2.securityGroup.dhall
in let Tag           = ../types/aws.ec2.tag.dhall
in let defaultInstance      = ../default/aws.ec2.instance.dhall
in let defaultSecurityGroup = ../default/aws.ec2.securityGroup.dhall
in let defaultTag           = ../default/aws.ec2.tag.dhall

-- and our instance
in let fooInstance = ./instance-foo.dhall

-- Generate the spec for the instance
in let spec = defaultInstance
{
  ami = fooInstance.ami
 ,instance_type = fooInstance.instance_type
 ,security_groups = (todo map the sg to the default constructor)
 ,tags = (same as security_groups)
}

in spec
```