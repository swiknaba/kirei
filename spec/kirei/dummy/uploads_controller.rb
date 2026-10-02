# typed: strict

module Dummy
  class UploadsController < Kirei::Controller
    sig { returns(T.anything) }
    def create
      file = T.cast(params.fetch("file"), Rack::Multipart::UploadedFile)

      render(
        Oj.dump(
          {
            "filename" => file.original_filename,
            "content_type" => file.content_type,
            "content" => file.read,
            "description" => params["description"],
          },
        ),
      )
    end
  end
end
