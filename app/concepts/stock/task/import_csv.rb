class Stock
  module Task
    class ImportCSV < Trailblazer::Operation
      pass :log_import_start
      step :file_exists?
      fail :log_file_not_found
      step :create_progressbar
      step :file_importer
      step :import_csv
      pass :log_import_completed

      def file_exists?(_, csv:, **)
        File.exist? csv
      end

      def create_progressbar(ctx, csv:, **)
        ctx[:progress_bar] = ProgressBar.create(
          total: number_of_rows(csv),
          format: 'Progress %c/%C (%P %%) |%b>%i| %a %e'
        )
      end

      def file_importer(ctx, logger:, **)
        ctx[:file_importer] = Files::Helper::FileImporter.new(logger)
      end

      def import_csv(_, csv:, model:, progress_bar:, file_importer:, **)
        file_importer.bulk_import(file: csv, model: model) do |imported_row_count|
          break unless imported_row_count
          imported_row_count.times { progress_bar.increment }
        end
      end

      def log_import_start(_, csv:, logger:, **)
        logger.info "Import starting for file #{csv}"
      end

      def log_file_not_found(_, logger:, csv:, **)
        logger.error "File not found: #{csv}"
      end

      def log_import_completed(_, logger:, **)
        logger.info 'Import completed.'
      end

      private

      def number_of_rows(csv)
        `wc -l #{csv}`.split.first.to_i - 1
      end

      def basic_options
        {
          chunk_size: 2_000,
          col_sep: ',',
          row_sep: "\n",
          downcase_header: false,
          convert_values_to_numeric: false,
          remove_empty_values: false,
          file_encoding: 'UTF-8'
        }
      end
    end
  end
end