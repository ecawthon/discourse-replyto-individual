# name: replyto-individual plugin
# about: A plugin that allows exposure of the sender's email address for functionality
#        similar to GNU/Mailman's Reply_Goes_To_List = Poster
# version: 0.0.1
# authors: Tarek Loubani <tarek@tarek.org>
# license: aGPLv3

PLUGIN_NAME ||= "replyto-individual".freeze


after_initialize do
  Email::MessageBuilder.class_eval do

    def build_args
      p = Post.find_by_id(@opts[:post_id])
      result = {
       to: @to,
       cc: @reply_by_email_address,
       subject: subject,
       body: body,
       charset: 'UTF-8',
       from: from_value
      }
      if allow_reply_by_email?
        if @opts[:private_reply] == true
          result['reply_to'] = reply_by_email_address
        else
          p = Post.find_by_id @opts[:post_id]
          result['from'] = "#{p.user.name} <#{p.user.email}>"
          result['reply_to'] = "#{p.user.name} <#{p.user.email}>"
          result['cc'] = reply_by_email_address
        end
      end
      result
    end

  end
end
