import pygit2
from pathlib import *
import subprocess
from color_logs import log

def delete_dir_and_contents(pth):
    for sub in pth.iterdir():
        if sub.is_dir():
            delete_dir_and_contents(sub)
        else:
            sub.unlink()
    pth.rmdir()


def form_authtoken_url(repo_tag, candidate_spec, user_spec):

    if Path(user_spec['github']['authtoken']).exists():
        authtoken = user_spec['github']['authtoken']
    else:
        #then the authtoken is a file to be dumped.
        authtoken= subprocess.Popen(["cat","/Users/james/.github_authtoken"],
                                    stdout=subprocess.PIPE).communicate()[0].decode("utf-8")

    auth_info = user_spec['github']['username']+':'+authtoken
    url = 'https://'+auth_info+'@github.com/'+candidate_spec[repo_tag]['fork']

    return(url)


def clone(repo_tag, candidate_spec, user_spec, dir_for_clone):
    
    url = form_authtoken_url(repo_tag, candidate_spec, user_spec)
    log.debug('Cloning '+candidate_spec[repo_tag]['fork'] +
              ' into '+str(dir_for_clone))
    repo = pygit2.clone_repository( url, str(dir_for_clone) )
    return(repo)


def establish_repo(repo_tag, candidate_spec, user_spec):

    repo_tag_base = repo_tag.split('_')[0]

    # The case when local_path is not set.
    if candidate_spec[repo_tag]['local_path'] == '':

        candidate_spec[repo_tag]['local_path_setby'] = 'fork & commitish'

        dir_for_clone = Path(candidate_spec['repos_dir']+'/'+repo_tag_base)

        if dir_for_clone.exists():
            delete_dir_and_contents(dir_for_clone)

        Path.mkdir(dir_for_clone, parents=True)

        repo = clone(repo_tag, candidate_spec, user_spec, dir_for_clone)

        # THis is total failure
        #repo.checkout(refname='1b18d3317012ee96725f6a090524e18e7d09845e')
        # https://stackoverflow.com/questions/43886483/replicating-git-checkout-commit-with-pygit2
        # TODO JLM: move to GitPython
        #subprocess.Popen(["git","checkout 1b18d3317012ee96725f6a090524e18e7d09845e"],
        #                 stdout=subprocess.PIPE)
        
        
        
    else:
        candidate_spec[repo_tag]['local_path_setby'] = 'candidate spec'    

    
