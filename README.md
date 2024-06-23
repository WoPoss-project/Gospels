# The WoPoss dataset on modality in the Gospels

Linguistic annotation (including modality) of the Gospels in Ancient Greek and Latin

## Contents

- `xml`: contains the XML-TEI dataset. There is a file for each language and Gospel. These files contain the linguistic annotation of modal passages (with three verses before and after each occurrence of a modal marker to provide context).

- `summary`: two tabular sheets with a summary of the annotation.

- `scripts`: XQuery code to create the tables presented in `summary` and to align the semantic annotation in Greel and Latin with any other language available in the project [_Multilingual Bible Parallel Corpus_](https://christos-c.com/bible/).

- `to-be-aligned`: empty folder where you need to save the files downloaded from the _Multilingual Bible Parallel Corpus_ in order to be aligned.

- `build.xml`: Apache Ant build file: read instructions to run it

## Aligning the semantic annotation with other languages
- You can either run directly the XQuery program `alignment.xquery` (folder `scripts`) or
- you can run it through `ant`. 

To carry out the alignment:
1. Download any XML files from the _Multilingual Bible Parallel Corpus_ [website](https://christos-c.com/bible/) or [GitHub repository](https://github.com/christos-c/bible-corpus) and save it in the folder `to-be-aligned`.
2. Open the terminal and run:
```
ant align
```
3. If you want to regenerate the summary tables, you can run:
```
ant analysis
```

### Requirements
You need to have installed Apache Ant. Your OS might already have Apache Ant preinstalled: you can verify it by opening the terminal and running:
```
ant -v
```

If you don’t have Ant, there are several tutorials online adapted to your OS. To cite a few:
- Mac OS: https://mkyong.com/ant/how-to-apache-ant-on-mac-os-x/
- Windows: https://mkyong.com/ant/how-to-install-apache-ant-on-windows/ 
- Ubuntu: https://www.osradar.com/install-apache-ant-ubuntu-20-04/ 

## How to cite 

– to cite the dataset: Dell’Oro, Francesca and Bermúdez Sabel, Helena (2023). The WoPoss dataset on modality in the Gospels. https://github.com/WoPoss-project/Gospels. 10.5281/zenodo.7599972

- to cite this project: Bermúdez Sabel, Helena and Dell’Oro, Francesca (2024). [An Annotated Multilingual Dataset to Study Modality in the Gospels](https://www.digitalhumanities.org/dhq/vol/18/1/000737/000737.html). Digital Humanities Quaterly 18.1. https://www.digitalhumanities.org/dhq/vol/18/1/000737/000737.html

– to cite single Latin files: 

Dell’Oro, Francesca; Bermúdez Sabel, Helena; von Kaenel, Thomas (2023). Evangelium secundum Matthaeum, translated by Jerome of Stridon, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

Dell’Oro, Francesca; Bermúdez Sabel, Helena; von Kaenel, Thomas (2023). Evangelium secundum Marcum, translated by Jerome of Stridon, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

Dell’Oro, Francesca; Bermúdez Sabel, Helena; Reymond, Séverine (2023). Evangelium secundum Lucam, translated by Jerome of Stridon, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

Dell’Oro, Francesca; Bermúdez Sabel, Helena; von Kaenel, Thomas (2023). Evangelium secundum Ioannem, translated by Jerome of Stridon, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

– to cite single Greek files: 

Dell’Oro, Francesca; Bermúdez Sabel, Helena; von Kaenel, Thomas (2023). Evangelium secundum Matthaeum, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

Dell’Oro, Francesca; Bermúdez Sabel, Helena; von Kaenel, Thomas (2023). Evangelium secundum Marcum, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

Dell’Oro, Francesca; Bermúdez Sabel, Helena; Reymond, Séverine (2023). Evangelium secundum Lucam, annotated according to the WoPoss guidelines. Swiss National Science Foundation.

Dell’Oro, Francesca; Bermúdez Sabel, Helena; von Kaenel, Thomas (2023). Evangelium secundum Ioannem, annotated according to the WoPoss guidelines. Swiss National Science Foundation.



