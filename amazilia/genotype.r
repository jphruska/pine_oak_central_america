# popmap = individual base names of fastq files, one line per individual

# make sure reference is indexed with bwa and samtools before use, and use CreateSequenceDictionary in GATK 
	
	project_directory <- "/lustre/scratch/johruska/central_america_pine_oak/amazilia"
	directory_name <- "amazilia_genotype"
	reference_genome_location <- "/lustre/scratch/johruska/central_america_pine_oak/amazilia/amazilia_ref/bCalAnn1.pri.cur.20181019.fasta"
	queue <- "omni"
	cluster <- "quanah"
	output_name <- "amazilia_genotype"
	popmap <- "amazilia_popmap.txt"
	individuals <- read.table(popmap, sep="\t")

	# input some items 
	manual_identification <- FALSE # whether using a fai index or manually inputting chromosomes
	genome_index <- "bCalAnn1.pri.cur.20181019.fasta.fai" # for use without manual input
	minimum_scaffold_size <- 0 # minimum scaffold size to include
	approximate_genotype_size <- 75000000 # amount to shoot for genotyping per script (will vary a bit from this)

	# genotype groupings
	if(manual_identification == TRUE) { # if manually adjusting, input the chromosomes here per job
		chr_list_to_genotype <- c()
	} else { # otherwise, the script will use the fai file to determine the scaffolds to genotype together
		# create job counter
		job_counter <- 1
		# create subset list
		subset_list <- list()
		chr_list_to_genotype <- c()
		# read in fai file
		gen_index <- read.table(genome_index, sep="\t", stringsAsFactors=F)
		# subset to minimum size
		gen_index <- gen_index[gen_index[,2] >= minimum_scaffold_size, c(1,2)]
		
		# move through and subset the fai index into discrete groupings
		while(nrow(gen_index) > 0) {
			number_scaffolds <- length(gen_index[(cumsum(gen_index[,2]) <= approximate_genotype_size) == T, 1]) + 1
			# reduce the number of scaffolds if at the end of the list
			if(number_scaffolds > nrow(gen_index)) {
				number_scaffolds <- number_scaffolds - 1
			}
			# extract the scaffold names
			subset_list[[job_counter]] <- gen_index[1:number_scaffolds, 1]
			for(a in 1:length(subset_list[[job_counter]])) {
				if(a == 1) {
					a_rep <- subset_list[[job_counter]][a]
				} else {
					a_rep <- paste(a_rep, " -L ", subset_list[[job_counter]][a], sep="")
				}
			}
			chr_list_to_genotype <- c(chr_list_to_genotype, a_rep)
			
			# add to counter
			job_counter <- job_counter + 1
			
			# remove the rows from the index
			gen_index <- gen_index[-(1:number_scaffolds), ]
		}
	}

	# naming schema
	if(manual_identification == TRUE) {
		batch_names <- chr_list_to_genotype
	} else {
		batch_names <- paste("batch_", seq(from=1, to=length(chr_list_to_genotype), by=1), sep="")
	}

	# make directories
	dir.create(directory_name)
	dir.create(paste(directory_name, "/01_gatk_split", sep=""))
	dir.create(paste(directory_name, "/02_gatk_combine", sep=""))
	dir.create(paste(directory_name, "/02b_gatk_database", sep=""))
	dir.create(paste(directory_name, "/03_group_genotype", sep=""))
	dir.create(paste(directory_name, "/03b_group_genotype_database", sep=""))



	# step 1
	# genotype all individuals using GATK, one array job per chromosome (manual) or per batch (fai generated)
	for(a in 1:length(chr_list_to_genotype)) {
		a.name <- paste(project_directory, "/01_bam_files/", "${SGE_TASK_ID}", "_final.bam", sep="")
		a.script <- paste(directory_name, "/01_gatk_split/", batch_names[a], ".sh", sep="")
		write("#!/bin/sh", file=a.script)
		write("#$ -V", file=a.script, append=T)
		write("#$ -cwd", file=a.script, append=T)
		write("#$ -S /bin/bash", file=a.script, append=T)
		write(paste("#$ -N ", batch_names[a], "_step1", sep=""), file=a.script, append=T)
		write(paste("#$ -q ", queue, sep=""), file=a.script, append=T)
		write("#$ -pe sm 4", file=a.script, append=T)
		write(paste("#$ -P ", cluster, sep=""), file=a.script, append=T)
		write("#$ -l h_rt=48:00:00", file=a.script, append=T)
		write("#$ -l h_vmem=10G", file=a.script, append=T)
		write(paste("#$ -t 1:5", sep=""), file=a.script, append=T)
		write("", file=a.script, append=T)
		write("module load intel java", file=a.script, append=T)
		write("", file=a.script, append=T)
		#gatk 4.0
		gatk_command <- paste('/lustre/work/jmanthey/gatk-4.1.0.0/gatk --java-options "-Xmx40g" HaplotypeCaller -R ', reference_genome_location, " -I ", a.name, " -ERC GVCF -O ", project_directory, "/02_vcf/", batch_names[a], "._${SGE_TASK_ID}_.g.vcf", " --QUIET -L ", chr_list_to_genotype[a], sep="")
		write(gatk_command, file=a.script, append=T)
	}

	# step 2 
	# combine the vcfs for each chromosome and each individual
	for(a in 1:length(chr_list_to_genotype)) {
		a.script <- paste(directory_name, "/02_gatk_combine/", batch_names[a], ".sh", sep="")
		write("#!/bin/sh", file=a.script)
		write("#$ -V", file=a.script, append=T)
		write("#$ -cwd", file=a.script, append=T)
		write("#$ -S /bin/bash", file=a.script, append=T)
		write(paste("#$ -N ", batch_names[a], "_step2", sep=""), file=a.script, append=T)
		write(paste("#$ -q ", queue, sep=""), file=a.script, append=T)
		write("#$ -pe sm 4", file=a.script, append=T)
		write(paste("#$ -P ", cluster, sep=""), file=a.script, append=T)
		write("#$ -l h_rt=48:00:00", file=a.script, append=T)
		write("#$ -l h_vmem=10G", file=a.script, append=T)
		write(paste("#$ -t 1:1", sep=""), file=a.script, append=T)
		write("", file=a.script, append=T)
		write("module load intel java", file=a.script, append=T)
		write("", file=a.script, append=T)
		
		#make list of all vcfs
		for(b in 1:nrow(individuals)) {
			if(b == 1) {
				vcf_total <- paste("--variant ", project_directory, "/02_vcf/", batch_names[a], "._", b, "_.g.vcf", sep="")
			} else {
				vcf_total <- paste(vcf_total, " --variant ", project_directory, "/02_vcf/", batch_names[a], "._", b, "_.g.vcf", sep="")
			}
		}
		
		#gatk 4.0
		gatk_command <- paste('/lustre/work/jmanthey/gatk-4.1.0.0/gatk --java-options "-Xmx40g" CombineGVCFs -R ', reference_genome_location, " ", vcf_total, " -O ", project_directory, "/02_vcf/", batch_names[a], ".g.vcf", sep="")
		write(gatk_command, file=a.script, append=T)
	}
  

	# step 3 
	# group genotype
	for(a in 1:length(chr_list_to_genotype)) {
		a.script <- paste(directory_name, "/03_group_genotype/", batch_names[a], ".sh", sep="")
		write("#!/bin/sh", file=a.script)
		write("#$ -V", file=a.script, append=T)
		write("#$ -cwd", file=a.script, append=T)
		write("#$ -S /bin/bash", file=a.script, append=T)
		write(paste("#$ -N ", batch_names[a], "_step3", sep=""), file=a.script, append=T)
		write(paste("#$ -q ", queue, sep=""), file=a.script, append=T)
		write("#$ -pe sm 10", file=a.script, append=T)
		write(paste("#$ -P ", cluster, sep=""), file=a.script, append=T)
		write("#$ -l h_rt=48:00:00", file=a.script, append=T)
		write("#$ -l h_vmem=10G", file=a.script, append=T)
		write(paste("#$ -t 1:1", sep=""), file=a.script, append=T)
		write("", file=a.script, append=T)
		write("module load intel java", file=a.script, append=T)
		write("", file=a.script, append=T)
		
		#gatk 4.0
		gatk_command <- paste('/lustre/work/jmanthey/gatk-4.1.0.0/gatk --java-options "-Xmx100g" GenotypeGVCFs -R ', reference_genome_location, " -V ", project_directory, "/02_vcf/", batch_names[a], ".g.vcf --include-non-variant-sites -O ", project_directory, "/03_vcf/", batch_names[a], ".g.vcf", sep="")
		write(gatk_command, file=a.script, append=T)
	}
	
	# alternate using genomicsdbimport
	
	
	# step 2 alternate
	# combine the vcfs for each chromosome and each individual
	for(a in 1:length(chr_list_to_genotype)) {
	  a.script <- paste(directory_name, "/02b_gatk_database/", batch_names[a], ".sh", sep="")
	  write("#!/bin/sh", file=a.script)
	  write("#$ -V", file=a.script, append=T)
	  write("#$ -cwd", file=a.script, append=T)
	  write("#$ -S /bin/bash", file=a.script, append=T)
	  write(paste("#$ -N ", batch_names[a], "_step2", sep=""), file=a.script, append=T)
	  write(paste("#$ -q ", queue, sep=""), file=a.script, append=T)
	  write("#$ -pe sm 4", file=a.script, append=T)
	  write(paste("#$ -P ", cluster, sep=""), file=a.script, append=T)
	  write("#$ -l h_rt=48:00:00", file=a.script, append=T)
	  write("#$ -l h_vmem=10G", file=a.script, append=T)
	  write(paste("#$ -t 1:1", sep=""), file=a.script, append=T)
	  write("", file=a.script, append=T)
	  write("module load intel java", file=a.script, append=T)
	  write("", file=a.script, append=T)
	  
	  #make list of all vcfs
	  for(b in 1:nrow(individuals)) {
	    if(b == 1) {
	      vcf_total <- paste("-V ", project_directory, "/02_vcf/", batch_names[a], "._", b, "_.g.vcf", sep="")
	    } else {
	      vcf_total <- paste(vcf_total, " -V ", project_directory, "/02_vcf/", batch_names[a], "._", b, "_.g.vcf", sep="")
	    }
	  }
	  
	  #gatk 4.0
	  gatk_command <- paste('/lustre/work/jmanthey/gatk-4.1.0.0/gatk --java-options "-Xmx40g" GenomicsDBImport ', vcf_total, " --genomicsdb-workspace-path ", project_directory, "/02_vcf/", batch_names[a], " -L ", chr_list_to_genotype[a], sep="")
	  write(gatk_command, file=a.script, append=T)
	}
	
	
	
	
	
	# step 3 
	# alternative group genotype with database
	for(a in 1:length(chr_list_to_genotype)) {
	  a.script <- paste(directory_name, "/03b_group_genotype_database/", batch_names[a], ".sh", sep="")
	  write("#!/bin/sh", file=a.script)
	  write("#$ -V", file=a.script, append=T)
	  write("#$ -cwd", file=a.script, append=T)
	  write("#$ -S /bin/bash", file=a.script, append=T)
	  write(paste("#$ -N ", batch_names[a], "_step3", sep=""), file=a.script, append=T)
	  write(paste("#$ -q ", queue, sep=""), file=a.script, append=T)
	  write("#$ -pe sm 10", file=a.script, append=T)
	  write(paste("#$ -P ", cluster, sep=""), file=a.script, append=T)
	  write("#$ -l h_rt=48:00:00", file=a.script, append=T)
	  write("#$ -l h_vmem=10G", file=a.script, append=T)
	  write(paste("#$ -t 1:1", sep=""), file=a.script, append=T)
	  write("", file=a.script, append=T)
	  write("module load intel java", file=a.script, append=T)
	  write("", file=a.script, append=T)
	  
	  #gatk 4.0
	  gatk_command <- paste('/lustre/work/jmanthey/gatk-4.1.0.0/gatk --java-options "-Xmx100g" GenotypeGVCFs -R ', reference_genome_location, " -V gendb://", project_directory, "/02_vcf/", batch_names[a], " -L ", chr_list_to_genotype[a], " --include-non-variant-sites -O ", project_directory, "/03_vcf/", batch_names[a], ".g.vcf", sep="")
	  write(gatk_command, file=a.script, append=T)
	}
