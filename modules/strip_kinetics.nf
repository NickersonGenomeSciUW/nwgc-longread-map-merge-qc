process STRIP_KINETICS {

    label "STRIP_KINETICS_${params.sampleId}_${params.userId}_$task.id"

    input:
        path bam

    output:
        path "*.primrose.bam",  emit: bam
        path "*.primrose.bam.bai",  emit: bai
        path "versions.yaml", emit: versions

    script:
        """
        if samtools view -H $bam | grep ^@PG | grep ID:primrose | grep -q keep-kinetics; then
            primrose \
                -j $task.cpus \
                $bam \
                ${bam}.primrose.bam;
        else
                cp $bam ${bam}.primrose.bam;
        fi

        samtools \
            index \
            -@ $task.cpus \
            ${bam}.primrose.bam

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            primrose: \$(primrose --version | grep ^primrose | awk '{print \$2}')
            samtools: \$(samtools --version | grep ^samtools | awk '{print \$2}')
        END_VERSIONS
        """

}