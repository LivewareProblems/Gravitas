# Gravitas

An agent to control your infrastructure.

The main goal of Gravitas is to provide help in managing your cloud infrastructure, without significant mental overhead for the user.

## Values

The values that guide the design of Gravitas are:

- *Observability*: The state and actions of Gravitas should be visible and easy to understand. Reasons for a decision and consequent action taken should be visible and *understandable* to a user.
- *Directability*: You need to be able to control and steer the direction Gravitas is going into, when you recognize a need to intervene. Gravitas should be flexible and able to take directions in the areas that need supervision, without the need for the user to take full control.  
- *Learnability*: Gravitas should be easy to pick up. We should also allow the user to grow their expertise alongside use of Gravitas. Gravitas handles a complex problem state and is itself a complex system. We consider that we should accompany our user from the first discovery of the system to being an expert of it.
- *Safety*: Gravitas needs to fulfill the highest standard for safety, security and ethics. We recognise our place in the ecosystem of software. As much as possible, we provide fail-safe situations and sane defaults. We aim to make the safe path easy. If a choice have to be made between resources and safety, Gravitas should balance its choice towards safety.
- *Stability*: As part of infrastructure, Gravitas' behaviour must be stable, and predictable. This means interfaces must be as stable as possible, upgrade paths must be easy and provided. Gravitas should allow services and workflow to be built on top of and around it.

## Hacking

Gravitas come with a [nix](https://nixos.org/nix/) environment. You will need to [add the dhall channels](https://hydra.dhall-lang.org/jobset/dhall-haskell/master/channel/latest). You can simply run `nix-shell` and get into hacking.

If you have problem installing `dhall` you may need to configure nix to accept the `dhall` cache server. Add to your [nix configuration](https://nixos.org/nix/manual/#sec-conf-file) the [dhall channels](https://github.com/dhall-lang/dhall-haskell#nix).
