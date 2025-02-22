# roary-nf
A nextflow pipeline for running [Roary](https://github.com/sanger-pathogens/Roary) pan-genome analysis on a set of GFF3 files.

## Usage

```
nextflow run BCCDC-PHL/roary-nf \
  --gff_path '</path/to/gff/files/*.gff' \
  --outdir </path/to/outdir>
```

The pipeline also supports a 'samplesheet input' mode. Pass a samplesheet.csv file with the headers `ID`, `GFF`:

```
nextflow run BCCDC-PHL/roary-nf \
  --samplesheet_input </path/to/samplesheet.csv> \
  --outdir </path/to/outdir>
```

## Parameters

The following parameters can be provided:
* `--min_identity`: Minimum percentage identity for blastp [default: 95]
* `--core_def_percentage`: Percentage of isolates a gene must be in to be core [default: 99]
* `--core_alignment`: Create a multiFASTA alignment of core genes using PRANK [default: false]
* `--fast_core_alignment`: Fast core gene alignment with MAFFT (use with core_alignment) [default: false]

## Outputs

The pipeline creates a directory structure under the specified output directory containing all Roary analysis outputs.

```
roary
├── roary_20240116154752_provenance.yml
├── pan_genome_reference.fa
├── gene_presence_absence.csv
├── gene_presence_absence.Rtab
├── core_gene_alignment.aln (if --core_alignment is used)
└── summary_statistics.txt
```

### Provenance
Each analysis will create a `provenance.yml` file. The filename includes a timestamp with format `YYYYMMDDHHMMSS` to ensure that a unique file will be produced if the analysis is re-run and outputs are stored to the same directory.

```yml
- process_name: roary
  tool_name: roary
  tool_version: 3.13.0
  parameters:
    min_identity: 95
    core_def_percentage: 99
    core_alignment: true
    fast_core_alignment: false
- input_filename: sample1.gff
  input_path: /path/to/gff/files/sample1.gff
  sha256: e291e09222b7f9a46968f4aa8c3a754c4b12758ea220d6e638a760d411e36697
- input_filename: sample2.gff
  input_path: /path/to/gff/files/sample2.gff
  sha256: f382e19333b7f9a46968f4aa8c3a754c4b12758ea220d6e638a760d411e36697
- pipeline_name: BCCDC-PHL/roary-nf
  pipeline_version: 0.1.0
- timestamp_analysis_start: 2024-01-16T09:05:01.524396
```
