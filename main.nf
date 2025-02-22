#!/usr/bin/env nextflow

import java.time.LocalDateTime

nextflow.enable.dsl = 2

include { hash_files } from './modules/hash_files.nf'
include { pipeline_provenance } from './modules/provenance.nf'
include { collect_provenance } from './modules/provenance.nf'
include { roary } from './modules/roary.nf'

workflow {
    ch_start_time = Channel.of(LocalDateTime.now())
    ch_pipeline_name = Channel.of(workflow.manifest.name)
    ch_pipeline_version = Channel.of(workflow.manifest.version)

    ch_pipeline_provenance = pipeline_provenance(ch_pipeline_name.combine(ch_pipeline_version).combine(ch_start_time))

    // Input handling
    if (params.samplesheet_input != 'NO_FILE') {
        ch_gff_files = Channel.fromPath(params.samplesheet_input)
            .splitCsv(header: true)
            .map{ it -> [it['ID'], it['GFF']] }
    } else {
        ch_gff_files = Channel.fromPath(params.gff_path)
            .map{ it -> [it.baseName.split('_')[0], it] }
            .unique{ it -> it[0] }
    }

    // Group all GFF files together for Roary
    ch_gff_collection = ch_gff_files.map{ it -> it[1] }.collect()

    main:
    // Hash input files
    hash_files(ch_gff_files.combine(Channel.of("gff-input")))

    // Run Roary
    roary(ch_gff_collection)

    // Collect provenance
    ch_provenance = roary.out.provenance
    ch_provenance = ch_provenance.combine(hash_files.out.provenance.map{ it -> it[1] }).map{ it -> ['roary', [it[0]] << it[1]] }
    ch_provenance = ch_provenance.combine(ch_pipeline_provenance).map{ it -> [it[0], it[1] << it[2]] }
    collect_provenance(ch_provenance)
}