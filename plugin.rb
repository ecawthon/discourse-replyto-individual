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

  Email::Sender.class_eval do

    def set_reply_key(post_id, user_id)
      return unless user_id &&
        post_id &&
        header_value(Email::MessageBuilder::ALLOW_REPLY_BY_EMAIL_HEADER).present?

      # use safe variant here cause we tend to see concurrency issue
      reply_key = PostReplyKey.find_or_create_by_safe!(
        post_id: post_id,
        user_id: user_id
      ).reply_key

      if @opts[:private_reply] == true
        @message.header['Reply-To'] =
          header_value('Reply-To').gsub!("%{reply_key}", reply_key)
      else
        @message.header['cc'] = header_value('cc').gsub!("%{reply_key}", reply_key)
      end
    end
  end
end
