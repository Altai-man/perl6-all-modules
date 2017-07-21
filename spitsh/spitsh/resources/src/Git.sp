#| The git command. Referencing this ensures that the git command is
#| installed.
#|{
    say ${ $:git status }
}
constant $:git = Cmd<git>.ensure-install;


#| GitURL represents something that can be passed to `git clone`.
class GitURL {
    #| Calls `git clone` on the the url and returns the path to the
    #| cloned directory.
    #|{
        GitURL<https://github.com/spitsh/spitsh.git/>.clone.cd;
        say ${ $:git status };
    }
    method clone(#|[Path to clone the repo to] :$to)-->File {
        info "starting git clone $self";
        my $_to = $to || $self.name;
        ok ${ $:git clone $self $_to !>debug('git-clone') },
           "$self cloned";
        $_to;
    }

    #| Gets the last section of the url without its extension. This is
    #| the same as directory name git will use to clone into by default.
    #|{ say GitURL<https://github.com/nodejs/node.git>.name #->node }
    method name~ {
        $self.${sed 's/\/$//;s/.*\///g;s/\.git$//'}
    }
}

#| GitHubRepo represents a github repo name like `nodejs/node`.
class GitHubRepo {

    #| Clones the GitHubRepo.
    #|{
        GitHubRepo<spitsh/spitsh>.clone.cd;
        say ${ $:git status };
    }
    method clone(#|[Path to clone the repo to] :$to)-->File {
        $self.url.clone(:$to);
    }

    #| Returns the owner part of the GitHubRepo.
    #|{ say GitHubRepo<nodejs/node>.owner #-> nodejs }
    method owner~ {
        $self.${sed 's/\/.*//'}
    }

    #| Returns the name part of the GitHubRepo.
    #|{ say GitHubRepo<nodejs/node>.name #-> node }
    method name~ {
        $self.${sed 's/.*\///'}
    }

    #| Long form of `.url`
    method GitURL { $self.url }

    #| Returns the https url for the repo
    #|{ GitHubRepo<nodejs/node>.url #-> https://github.com/nodejs/node.git }
    method url-->GitURL { "https://github.com/$self.git" }

    method release-url($tag)-->HTTP {
        HTTP("https://github.com/$self/releases/$tag")
    }
    method latest-release-url-->HTTP {
        $self.release-url("latest").redirect-url;
    }
}
