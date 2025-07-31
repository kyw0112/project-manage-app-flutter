import 'package:flutter/material.dart';
import 'package:actual/my_project/model/board_card_model.dart';

class BoardCardWidget extends StatelessWidget {
  final BoardCardModel card;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const BoardCardWidget({
    Key? key,
    required this.card,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildTitle(),
              if (card.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildDescription(),
              ],
              if (card.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildTags(),
              ],
              if (card.progressPercentage > 0) ...[
                const SizedBox(height: 8),
                _buildProgress(),
              ],
              const SizedBox(height: 8),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 카드 헤더 (우선순위 표시)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: card.priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            card.priorityText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: card.priorityColor,
            ),
          ),
        ),
        if (onDelete != null)
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.more_vert,
              size: 16,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }

  /// 카드 제목
  Widget _buildTitle() {
    return Text(
      card.title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 카드 설명
  Widget _buildDescription() {
    return Text(
      card.description,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        height: 1.3,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 태그들
  Widget _buildTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: card.tags.take(3).map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 10,
            color: Colors.blue[700],
          ),
        ),
      )).toList(),
    );
  }

  /// 진행률 표시
  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '진행률',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${card.progressPercentage}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: card.progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: card.progressPercentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(card.progressColor),
          minHeight: 3,
        ),
      ],
    );
  }

  /// 카드 푸터 (담당자, 마감일, 아이콘들)
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // 담당자 아바타
        if (card.assigneeName.isNotEmpty)
          _buildAssigneeAvatar(),
        
        const Spacer(),
        
        // 마감일
        if (card.dueDate != null)
          _buildDueDate(),
        
        // 기능 아이콘들
        if (card.displayIcons.isNotEmpty) ...[
          const SizedBox(width: 4),
          ..._buildActionIcons(),
        ],
      ],
    );
  }

  /// 담당자 아바타
  Widget _buildAssigneeAvatar() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        shape: BoxShape.circle,
      ),
      child: card.assigneeAvatar != null
          ? ClipOval(
              child: Image.network(
                card.assigneeAvatar!,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(),
              ),
            )
          : _buildAvatarFallback(),
    );
  }

  /// 아바타 대체 위젯
  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        card.assigneeName.isNotEmpty 
            ? card.assigneeName[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  /// 마감일 표시
  Widget _buildDueDate() {
    Color textColor = Colors.grey[600]!;
    Color backgroundColor = Colors.grey[100]!;
    
    if (card.isOverdue) {
      textColor = Colors.red[700]!;
      backgroundColor = Colors.red[50]!;
    } else if (card.isDueToday) {
      textColor = Colors.orange[700]!;
      backgroundColor = Colors.orange[50]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 10,
            color: textColor,
          ),
          const SizedBox(width: 2),
          Text(
            card.formattedDueDate,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 액션 아이콘들
  List<Widget> _buildActionIcons() {
    return card.displayIcons.map((icon) {
      Color iconColor = Colors.grey[500]!;
      
      // 아이콘별 색상 지정
      if (icon == Icons.priority_high) {
        iconColor = Colors.red;
      } else if (icon == Icons.schedule_outlined) {
        iconColor = Colors.red;
      } else if (icon == Icons.today) {
        iconColor = Colors.orange;
      }
      
      return Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Icon(
          icon,
          size: 12,
          color: iconColor,
        ),
      );
    }).toList();
  }
}