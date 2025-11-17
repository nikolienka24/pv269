version 1.0

workflow countNs_parallel {
  input {
    File data
  }

  call SplitFasta {
    input: input_file = data
  }

  scatter (seq in SplitFasta.seq_files) {
    call CountNs {
      input: input_file = seq
    }
  }

  call SumNs {
    input: numbers = CountNs.total_Ns
  }

  output {
    Int total_Ns = SumNs.sum
  }
}

task SplitFasta {
  input {
    File input_file
  }

  command <<<
    set -euo pipefail
    mkdir -p seqs

    seqtk seq ~{input_file} | awk '/^>/{f="seqs/seq_" ++i ".fa"} {print > f}'

    ls -l seqs
  >>>

  output {
    Array[File] seq_files = glob("seqs/*.fa")
  }

  runtime {
    docker: "biocontainers/seqtk:v1.3-1-deb_cv1"
  }
}

task CountNs {
  input {
    File input_file
  }

  command <<<
    grep -o -i "N" ~{input_file} | wc -l > count.txt || echo 0 > count.txt
  >>>

  output {
    Int total_Ns = read_int("count.txt")
  }

  runtime {
    docker: "ubuntu:22.04"
  }
}

task SumNs {
  input {
    Array[Int] numbers
  }

  command <<<
    echo "~{sep='\n' numbers}" | awk '{s+=$1} END {print s}' > sum.txt
  >>>

  output {
    Int sum = read_int("sum.txt")
  }

  runtime {
    docker: "ubuntu:22.04"
  }
}
