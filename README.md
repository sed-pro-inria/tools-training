mds-training
============

Training supports

Install miniconda3, from:

    http://conda.pydata.org/miniconda.html

Install IPython notebook:

    conda install ipython-notebook

Start IPython notebook:

    ipython notebook --browser=firefox

To export notebook to PDF, install pygments:

    conda install pygments

Execute nbconvert:

    ipython nbconvert git.ipynb --to latex --post PDF
