{-
`instance` provide the type to generate EC2 instances

-}
    let SecurityGroup = ./aws.ec2.securityGroup.dhall

in  let Tag = ./aws.ec2.tag.dhall

in  let Instance
        : Type
        = { ami :
              Text
          , instance_type :
              Text
          , availability_zone :
              Optional Text
          , tenancy :
              Optional Text
          , ebs_optimized :
              Optional Bool
          , disable_api_termination :
              Optional Bool
          , key_name :
              Optional Text
          , monitoring :
              Optional Bool
          , security_groups :
              List SecurityGroup
          , subnet_id :
              Optional Text
          , associate_public_ip :
              Optional Bool
          , iam_instance_profile :
              Optional Text
          , tags :
              List Tag
          , region :
              Optional Text
          }

in  Instance
