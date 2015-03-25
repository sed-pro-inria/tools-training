mds-training
============

Install the package manager miniconda3, from:

    http://conda.pydata.org/miniconda.html

Create a conda environment 'mds-training', containing required packages:

    conda create -n mds-training python=3 ipython-notebook==2.4.1 pygments

Activate the 'mds-training' conda environment:

    source activate mds-training

Start IPython notebook:

    ipython notebook --browser=firefox

To export notebook to PDF, execute nbconvert:

    ipython nbconvert git.ipynb --to latex --post PDF
