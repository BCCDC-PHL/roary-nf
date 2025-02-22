process roary {

    publishDir "${params.outdir}", pattern: "roary_output/*", mode: 'copy'

    input:
    path(gff_files)

    output:
    path("roary_output/"), emit: results
    path("roary_provenance.yml"), emit: provenance

    script:
    def args = task.ext.args ?: ''
    def fast_core_alignment = params.fast_core_alignment ? '-n' : ''
    def core_alignment = params.core_alignment ? '-e' : ''
    """
    printf -- "- process_name: roary\\n" > roary_provenance.yml
    printf -- "  tool_name: roary\\n  tool_version: \$(roary -w 2>&1 | grep "Version:" | cut -d ' ' -f 2)\\n  parameters:\\n" >> roary_provenance.yml
    
    roary \
        -p ${task.cpus} \
        -f roary_output \
        ${core_alignment} \
        ${fast_core_alignment} \
        -i ${params.min_identity} \
        -cd ${params.core_def_percentage} \
        $args \
        ${gff_files}
    """
}