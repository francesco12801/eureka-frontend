import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CollaboratorListTile extends StatelessWidget {
  final EurekaUser user;
  final bool isSelected;
  final VoidCallback onTap;

  const CollaboratorListTile({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E4E3A) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? greenIOS.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? greenIOS : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                user.profileImage ?? 'https://www.gravatar.com/avatar/?d=mp',
              ),
            ),
          ),
          title: Text(
            user.nameSurname,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            user.profession,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? greenIOS.withOpacity(0.2)
                  : const Color(0xFF3A3A3A),
              border: Border.all(
                color: isSelected ? greenIOS : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              isSelected ? CupertinoIcons.check_mark : CupertinoIcons.add,
              color: isSelected ? greenIOS : Colors.white.withOpacity(0.8),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedCollaboratorChip extends StatelessWidget {
  final EurekaUser collaborator;
  final VoidCallback onRemove;

  const SelectedCollaboratorChip({
    super.key,
    required this.collaborator,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: white,
                  width: 0.5,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: NetworkImage(
                  collaborator.profileImage ??
                      'https://www.gravatar.com/avatar/?d=mp',
                ),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 164, 11, 0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.minus,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          collaborator.nameSurname.split(' ')[0],
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
