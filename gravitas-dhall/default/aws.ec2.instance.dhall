  λ ( _params
    : { ami :
          Text
      , instance_type :
          Text
      , security_groups :
          List ./../types/aws.ec2.securityGroup.dhall
      , tags :
          List ./../types/aws.ec2.tag.dhall
      }
    )
→   { ami =
        _params.ami
    , instance_type =
        _params.instance_type
    , availability_zone =
        [] : Optional Text
    , tenancy =
        [] : Optional Text
    , ebs_optimized =
        [] : Optional Text
    , disable_api_termination =
        [] : Optional Bool
    , key_name =
        [] : Optional Text
    , monitoring =
        [] : Optional Bool
    , security_groups =
        _params.security_groups
    , subnet_id =
        [] : Optional Text
    , associate_public_ip =
        [] : Optional Bools
    , iam_instance_profile =
        [] : Optional Text
    , tags =
        _params.tags
    , region =
        [] : Optional Text
    }
  : ./../types/aws.ec2.instance.dhall
