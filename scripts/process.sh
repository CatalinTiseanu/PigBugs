# author: Catalin-Stefan Tiseanu
# script for transforming to a .csv file from Pig Forma
# obviously, we could output it directly to a comma separated format, but doing so introduce inflexibility
# cat .* > all_results
cat ml_file_ncss | sed -e 's/\t\+/,/g' > all_results_processed_tmp1
sed 's/(//' all_results_processed_tmp1 > all_results_processed_tmp2
sed 's/)//' all_results_processed_tmp2 > all_results_processed_ncss

