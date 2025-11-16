version 1.0

workflow count_Ns {
  input {
    File data
  }

  call CountNs { input: input_file = data }

  output {
    Int total_Ns = CountNs.total_Ns
  }
}

task CountNs {
    input {
        File input_file
    }

    command <<<
        grep -o -i "N" ~{input_file} | wc -l > count.txt
    >>>

    output {
        Int total_Ns = read_int("count.txt")
    }

    runtime {
        docker: "ubuntu:22.04"
    }
}