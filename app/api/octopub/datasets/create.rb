module Octopub
  module Datasets
    class Create < Grape::API

      desc 'Creates a dataset for an authenticated user.',
           detail: 'Returns a Job URL, which you can poll to check the creation status of a job',
           consumes: ['multipart/form-data'],
           success: 202,
           entity: Octopub::Entities::Job,
           http_codes: [
             { code: 202, message: 'OK', model: Octopub::Entities::Job }
           ],
           ignore_defaults: true
      params do
        requires :dataset, type: Hash do
          requires :name, type: String, desc: 'The name of the dataset'
          optional :description, type: String, desc: 'A short description of the dataset'
          optional :owner, type: String, desc: 'The Github organisation to publish the dataset to (see /api/user/organisations for a list)'
          requires :publisher_name, type: String, desc: 'The name of the person / organisation publishing the data'
          optional :publisher_url, type: String, desc: 'The website of the person / organisation publishing the data'
          requires :license, type: String, desc: 'The ID of the dataset\'s license', values: Octopub::API_LICENCES
          optional :frequency, type: String, desc: 'How freqently the dataset is updated', values: Octopub::PUBLICATION_FREQUENCIES
        end
        requires :file, type: Hash do
          requires :title, type: String, desc: 'The name of the file'
          optional :description, type: String, desc: 'A short description of the file'
          requires :file, type: File, desc: 'The actual file'
        end
      end
      post :datasets do
        authenticate!
        process_file(params.file)
        job = CreateDataset.perform_async(params.dataset, params.file, current_user.id)

        status 202
        Octopub::Entities::Job.represent(job)
      end

    end
  end
end
