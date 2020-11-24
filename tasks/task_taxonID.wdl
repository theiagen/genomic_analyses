task kraken2 {
  File        read1
  File 		  read2
  String      samplename
  String?     kraken2_db = "/kraken2-db"
  String? 	  cpus = "4"

  command{
    # date and version control
    date | tee DATE
    kraken2 --version | head -n1 | tee VERSION

    kraken2 --paired \
      --classified-out cseqs#.fq \
      --threads ${cpus} \
      --db ${kraken2_db} \
      ${read1} ${read2} \
      --report ${samplename}_kraken2_report.txt

    percentage_human=$(grep "Homo sapiens" ${samplename}_kraken2_report.txt | cut -f 1)
     # | tee PERCENT_HUMAN
    percentage_sc2=$(grep "Severe acute respiratory syndrome coronavirus 2" ${samplename}_kraken2_report.txt | cut -f1 )
     # | tee PERCENT_COV
    if [ -z "$percentage_human" ] ; then percentage_human="0" ; fi
    if [ -z "$percentage_sc2" ] ; then percentage_sc2="0" ; fi
    echo $percentage_human | tee PERCENT_HUMAN
    echo $percentage_sc2 | tee PERCENT_SC2
  }

  output {
    String     date = read_string("DATE")
    String     version = read_string("VERSION") 
    File 	   kraken_out = "${samplename}_kraken2_report.txt"
    String 	   percent_human = read_string("PERCENT_HUMAN")
    String 	   percnet_sc2 = read_string("PERCENT_SC2")
  }

  runtime {
    docker:       "staphb/kraken2:2.0.8-beta_hv"
    memory:       "8 GB"
    cpu:          4
    disks:        "local-disk 100 SSD"
    preemptible:  0      
  }
}






