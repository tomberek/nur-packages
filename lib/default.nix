{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # Split a file into chunks
  splitDrv = file : num :
  let numDigits = 3;
  in
    pkgs.runCommand "${file.name}.chunked" rec {
    chunks = builtins.genList (x: "x${fixedWidthNumber numDigits x}") num;
    outputs = ["out"] ++ chunks;
    src = file;
    passthru.original_name = file.name;
  } ''
    split -a ${toString numDigits} -d -n ${toString num} $src
    for i in $(find . -iname "x*" -exec basename {} \; | sort); do
      mv $i $(eval echo \$$i)
      printf '%s\n' $(eval echo \$$i) >> $out
    done
  '';

  joinDrv = file :
    pkgs.runCommand "${file.original_name}" {
      preferLocalBuild = true;
      allowSubstitutes = false;
    } ''
      cat ${file} | xargs cat > $out
  '';

}

