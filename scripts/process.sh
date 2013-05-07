# cat .* > all_results
cat all_results | sed -e 's/\t\+/,/g' > all_results_processed1
sed 's/((//' all_results_processed1 > all_results_processed2
sed 's/))//' all_results_processed2 > all_results_processed
