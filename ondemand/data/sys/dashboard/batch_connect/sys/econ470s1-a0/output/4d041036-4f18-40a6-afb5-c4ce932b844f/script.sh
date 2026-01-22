#!/usr/bin/env bash

# Benchmark info
echo "TIMING - Starting main script at: $(date)"

mkdir -p "$HOME"'/R/x86_64-conda-linux-gnu-library/4.3'
export TEXMFVAR="$HOME"'/.cache/texmf-var'

# Set working directory to home directory
cd "${HOME}"
# source config defaults
base_dir='/local'
term='5261'
# params
offering='econ470001'
assignment='a'"${assignment_number}"
offering_name='econ470'
# base environment
env_dir="${base_dir}/${term}/${offering}"
if [[ -f "${env_dir}/${assignment}"/'conda.sh' ]] ; then
  env_dir="${env_dir}/${assignment}"
fi
. "${env_dir}"/'conda.sh'
conda activate "${env_dir}"/'conda-env'

bin_dir="${base_dir}/${term}/${offering}"/'bin'
if [[ -d "${bin_dir}" ]] ; then
  PATH="${PATH}${PATH:+:}${bin_dir}"
fi

# venv
venv_dir="${HOME}/${offering_name}/${assignment}"
if [[ 'resetyes' == "${reset_assignment}" ]] ; then
  echo 'destructive reset option selected by user'
  ( cd "${HOME}" ; /bin/rm -rf '.local/share/jupyter/kernels/econ470-a0kernel' )
  if [[ -d "${venv_dir}" ]] ; then
    chmod 700 "${venv_dir}"
    /bin/mv "${venv_dir}" '/data/.del'/"${HOME##*/}-${assignment}.$(date +%Y%m%d.%H:%M:%S).$$"
  fi
fi
if [[ ! -d "${venv_dir}"/'pyenv' ]] ; then
  mkdir -p "${venv_dir}"
  python -m venv --system-site-packages "${venv_dir}"/'pyenv'
fi
. "${venv_dir}"/'pyenv/bin/activate'

# venv specific kernel
venv_kern_ent='econ470-'"${assignment}"'kernel'
venv_kern_label='Python ('"${assignment_label:-unlabeled}"')'
kern_dir="${HOME}"'/.local/share/jupyter/kernels/'"${venv_kern_ent}"
if [[ ! -d "${kern_dir}" ]] ; then
  python -m ipykernel install --prefix .local --name "${venv_kern_ent}" --display-name "${venv_kern_label}"
fi

#nb_args=''
if [[ "${HOME}/${home_subdir_work}" != "${venv_dir}"/'work' ]] ; then
  echo 'warning: working directory does not match'
fi
if [[ ! -d "${venv_dir}"/'work' ]] ; then
  work_src="${base_dir}/${term}/${offering}/${assignment}"'/src/dist'
  work_dst="${venv_dir}"/'work'
  mkdir -p "${work_dst}"
  rsync -r -l "${work_src}"/ "${work_dst}"
fi

# extra...
#export GENSIM_DATA_DIR="${venv_dir}"/'work/data/gensim-data'

#
# Start Jupyter Notebook Server
#


# Benchmark info
echo "TIMING - Starting jupyter at: $(date)"

# Launch the Jupyter Notebook Server
set -x
#jupyter lab --config="${CONFIG_FILE}" 
jupyter notebook --config="${CONFIG_FILE}" 
#jupyter notebook --config="${CONFIG_FILE}"  $nbargs
